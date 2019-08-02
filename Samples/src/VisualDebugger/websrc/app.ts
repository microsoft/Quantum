import "./css/main.css";
import * as signalR from "@aspnet/signalr";
import * as chart from "chart.js";

//#region Serialization contract

type State = {
    real: number,
    imaginary: number,
    magnitude: number,
    phase: number
}[];

//#endregion

//#region HTML elements

const olOperations: HTMLDivElement = document.querySelector("#olOperations");
const btnNext: HTMLButtonElement = document.querySelector("#btnNext");
const btnPrevious: HTMLButtonElement = document.querySelector("#btnPrevious");
const canvas: HTMLCanvasElement = document.querySelector("#chartCanvas");
const chartContext = canvas.getContext("2d");

//#endregion

const operations: HTMLLIElement[] = [];

type Snapshot = {
    state: State,
    lastOperation: HTMLLIElement,
    nextOperation: HTMLLIElement
};

type History = {
    snapshots: Snapshot[],
    position: number
};

const history: History = {
    snapshots: [],
    position: -1
};

const stateChart = new chart.Chart(chartContext, {
    type: "bar",
    data: {
        labels: [],
        datasets: [
            {
                data: [],
                label: "Real",
				backgroundColor: "#ff0000",
				borderColor: "#ff0000",
            },
            {
                data: [],
                label: "Imag",
				backgroundColor: "#0000ff",
				borderColor: "#0000ff",
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            yAxes: [{
                ticks: {
                    suggestedMin: -1,
                    suggestedMax: 1
                }
            }]
        }
    }
});

function updateChart(state: State) {
    let real = state.map(amplitude => amplitude.real);
    let imag = state.map(amplitude => amplitude.imaginary);
    let newCount = real.length;
    let nQubits = Math.log2(newCount) >>> 0;
    stateChart.data.datasets[0].data = real;
    stateChart.data.datasets[1].data = imag;
    stateChart.data.labels = Array.from(Array(state.length).keys()).map(idx => {
        let bitstring = (idx >>> 0).toString(2).padStart(nQubits, "0");
        return `|${bitstring}⟩`;
    });
    stateChart.update();
}

function goToHistory(position: number): void {
    const lastSnapshot = history.snapshots[history.position];
    if (lastSnapshot.lastOperation !== null) {
        lastSnapshot.lastOperation.className = "";
    }
    if (lastSnapshot.nextOperation !== null) {
        lastSnapshot.nextOperation.className = "";
    }

    const nextSnapshot = history.snapshots[position];
    if (nextSnapshot.lastOperation !== null) {
        nextSnapshot.lastOperation.className = "last";
    }
    if (nextSnapshot.nextOperation !== null) {
        nextSnapshot.nextOperation.className = "next";
    }
    history.position = position;
    updateChart(nextSnapshot.state);
}

function pushHistory(lastOperation: HTMLLIElement, nextOperation: HTMLLIElement, state: State): void {
    if (state === null) {
        state = history.snapshots.length === 0 ? [] : history.snapshots[history.snapshots.length - 1].state;
    }
    history.snapshots.push({ state, lastOperation, nextOperation });
    history.position = history.snapshots.length - 1;
}

//#region SignalR hub connection

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/events")
    .build();

connection.start().catch(err => document.write(err));

connection.on("operationStarted", onOperationStarted);
connection.on("operationEnded", onOperationEnded);

function onOperationStarted(operationName: string, input: number[]) {
    console.log(operationName, input);

    const last = olOperations.querySelector(".last");
    if (last !== null) {
        last.className = "";
    }

    const operation = document.createElement("li");
    operation.className = "next";
    operation.innerHTML =
        `<span class="operation-name">${operationName}</span>(<span class="operation-args">${input.join(", ")}</span>)`;

    if (operations.length == 0) {
        olOperations.appendChild(operation);
    } else {
        const last = operations[operations.length - 1];
        last.className = "";
        let children = last.querySelector(".operation-children");
        if (children === null) {
            children = document.createElement("ol");
            children.className = "operation-children";
            last.appendChild(children);
        }
        children.appendChild(operation);
    }
    olOperations.scrollTop = olOperations.scrollHeight;
    operations.push(operation);
    pushHistory(null, operation, null);
}

function onOperationEnded(output: any, state: State) {
    const last = olOperations.querySelector(".last");
    if (last !== null) {
        last.className = "";
    }
    
    const operation = operations.pop();
    operation.className = "last";

    // Show only return values that aren't unit.
    if (!(output instanceof Object) || Object.keys(output).length > 0) {
        operation.appendChild(document.createTextNode(` = ${output}`));
    }

    updateChart(state);
    pushHistory(operation, null, state);
    olOperations.scrollTop = olOperations.scrollHeight;
}

//#endregion

function advance(): Promise<boolean> {
    return getJSON<boolean>("/advance");
}

function next(): void {
    if (history.position == history.snapshots.length - 1) {
        advance();
    } else {
        goToHistory(history.position + 1);
    }
}

function previous(): void {
    if (history.position > 0) {
        goToHistory(history.position - 1);
    }
}

btnNext.addEventListener("click", next);
btnPrevious.addEventListener("click", previous);

// TODO: refactor advancing to use SignalR hub instead
//       of raw AJAX call.

function getJSON<TExpected>(url) {
    return new Promise<TExpected>((resolve, reject) => {
        let xhr = new XMLHttpRequest();

        xhr.open('GET', url);
        xhr.onreadystatechange = () => {
            if (xhr.readyState === xhr.DONE) {
                if (xhr.status === 200) {
                    resolve(xhr.response as TExpected);
                } else {
                    reject(new Error('getJSON: `' + url + '` failed with status: [' + xhr.status + ']'));
                }
            }
        };
        xhr.responseType = 'json';
        xhr.setRequestHeader('Accept', 'application/json');
        xhr.send();
    });
}
