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

const divMessages: HTMLDivElement = document.querySelector("#divMessages");
const olOperations: HTMLDivElement = document.querySelector("#olOperations");
const btnAdvance: HTMLButtonElement = document.querySelector("#btnAdvance");
const canvas: HTMLCanvasElement = document.querySelector("#chartCanvas");
const chartContext = canvas.getContext("2d");

//#endregion

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

function updateState() {
    getJSON<State>("/state").then(updateChart);
}

//#region SignalR hub connection

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/events")
    .build();

connection.start().catch(err => document.write(err));

connection.on("operationStarted", onOperationStarted);
connection.on("operationEnded", onOperationEnded);

function format(data: any) : string {
    console.log("formatting:", data, typeof(data));
    if (data instanceof Object && Object.keys(data).length == 0) {
        // Empty tuple.
        return "()"
    }
    // TODO: consider arity 9, 8, …, 4.
    else if (data instanceof Object && "item3" in data) {
        return `(${format(data.item1)}, ${format(data.item2)}, ${format(data.item3)})`;
    }
    else if (data instanceof Object && "item2" in data) {
        return `(${format(data.item1)}, ${format(data.item2)})`;
    }
    else if (data instanceof Object && "item1" in data) {
        return `(${format(data.item1)})`;
    }
    else if (typeof(data) == "string") {
        return `"${data}"`;
    }
    else return data.toString();
}

const operations: HTMLLIElement[] = [];

function onOperationStarted(operationName: string, input: any) {
    console.log(operationName, input);
    const operation = document.createElement("li");
    operation.innerHTML =
        `<span class="operation-name">${operationName}</span>(<span class="operation-args">${format(input)}</span>)`;

    if (operations.length == 0) {
        olOperations.appendChild(operation);
    } else {
        const last = operations[operations.length - 1];
        let children = last.querySelector(".operation-children");
        if (children === null) {
            children = document.createElement("ol");
            children.className = "operation-children";
            last.appendChild(children);
        }
        children.appendChild(operation);
    }
    divMessages.scrollTop = divMessages.scrollHeight;
    operations.push(operation);
}

function onOperationEnded(output: any) {
    const operation = operations.pop();
    operation.innerHTML += ` = ${format(output)}`;
    divMessages.scrollTop = divMessages.scrollHeight;
    updateState();
}

//#endregion

function advance(): Promise<boolean> {
    return getJSON<boolean>("/advance");
}

btnAdvance.addEventListener("click", advance);

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
