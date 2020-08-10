// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import "./css/main.css";
import * as signalR from "@aspnet/signalr";
import * as chart from "chart.js";
import { executionPathToHtml } from "./ExecutionPathVisualizer";
import { ExecutionPath } from "./ExecutionPathVisualizer/executionPath";

//#region Serialization contract

type State = {
    real: number,
    imaginary: number,
    magnitude: number,
    phase: number
}[];

//#endregion

//#region HTML elements

const divOperations: HTMLDivElement = document.querySelector("#divOperations");
const olOperations: HTMLOListElement = document.querySelector("#olOperations");
const btnStepIn: HTMLButtonElement = document.querySelector("#btnStepIn");
const btnStepOver: HTMLButtonElement = document.querySelector("#btnStepOver");
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
            yAxes: [
                {
                    ticks: {
                        suggestedMin: -1,
                        suggestedMax: 1
                    }
                }
            ]
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

function clearIcon(): void {
    const next = olOperations.querySelector(".next");
    if (next !== null) {
        next.className = "";
    }
    const last = olOperations.querySelector(".last");
    if (last !== null) {
        last.className = "";
    }
}

function getCurrentOperation(): HTMLLIElement {
    const snapshot = history.snapshots[history.position];
    return snapshot.nextOperation !== null ? snapshot.nextOperation : snapshot.lastOperation;
}

function getLevel(operation: HTMLLIElement): number {
    if (operation.parentElement === null) {
        throw new Error("Operation is not in olOperations");
    } else if (operation.parentElement === olOperations) {
        return 0;
    } else if (operation.parentElement.parentElement instanceof HTMLLIElement) {
        return 1 + getLevel(operation.parentElement.parentElement);
    }
}

function getOffsetTop(operation: HTMLElement): number {
    if (!olOperations.contains(operation.offsetParent)) {
        return 0;
    } else {
        return operation.offsetTop + getOffsetTop(operation.offsetParent as HTMLElement);
    }
}

function scrollToCurrentOperation(): void {
    const snapshot = history.snapshots[history.position];
    const operationEnded = snapshot.lastOperation !== null;
    const operation = operationEnded ? snapshot.lastOperation : snapshot.nextOperation;

    let target: HTMLElement;
    if (operationEnded) {
        const children = operation.querySelectorAll(".operation-name");
        target = children[children.length - 1] as HTMLElement;
    } else {
        target = operation.querySelector(".operation-name");
    }

    const offsetTop = getOffsetTop(target);
    if (offsetTop < divOperations.scrollTop) {
        target.scrollIntoView(true);
    } else if (offsetTop + target.offsetHeight > divOperations.scrollTop + divOperations.offsetHeight) {
        target.scrollIntoView(false);
        divOperations.scrollTop += 5;
    }
}

function appendOperation(operation: HTMLLIElement): void {
    if (operations.length === 0) {
        olOperations.appendChild(operation);
    } else {
        operations[operations.length - 1].querySelector(".operation-children").appendChild(operation);
    }
    olOperations.scrollTop = olOperations.scrollHeight;
}

//#region SignalR hub connection

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/events")
    .build();

connection.start().catch(err => document.write(err));

connection.on("OperationStarted", onOperationStarted);
connection.on("OperationEnded", onOperationEnded);
connection.on("Log", onLog);

function onOperationStarted(operationName: string, input: number[], state: State, executionPath: ExecutionPath): void {
    console.log("Operation start:", operationName, input);

    clearIcon();
    const operation = document.createElement("li");
    operation.className = "next";
    operation.innerHTML =
        '<span class="operation-name"></span>' +
        '(<span class="operation-args"></span>)' +
        '<ol class="operation-children"></ol>';
    operation.querySelector(".operation-name").textContent = operationName;
    operation.querySelector(".operation-args").textContent = input.join(", ");
    appendOperation(operation);
    operations.push(operation);
    updateChart(state);

    pushHistory(null, operation, state);

    // Render circuit visualization
    const html: string = executionPathToHtml(executionPath);
    const container: HTMLElement = document.getElementById("circuit-container");
    if (container == null) throw new Error("circuit-container div not found.");
    container.innerHTML = html;
}

function onOperationEnded(returnValue: string, state: State): void {
    console.log("Operation end:", returnValue);

    clearIcon();
    const operation = operations.pop();
    operation.className = "last";
    if (returnValue !== "()") {
        // Show only return values that aren't unit.
        operation.appendChild(document.createTextNode(` = ${returnValue}`));
    }

    updateChart(state);
    pushHistory(operation, null, state);
    olOperations.scrollTop = olOperations.scrollHeight;
}

function onLog(message: string, state: State): void {
    console.log("Log: ", message);

    clearIcon();
    const operation = document.createElement("li");
    operation.className = "next";
    operation.innerHTML = '<span class="operation-name"></span>';
    operation.querySelector(".operation-name").textContent = message;
    appendOperation(operation);
    updateChart(state);

    pushHistory(null, operation, state);
}

function nextEvent(): Promise<void> {
    return new Promise((resolve, reject) => {
        function finish(): void {
            resolve();
            connection.off("OperationStarted", finish);
            connection.off("OperationEnded", finish);
            connection.off("Log", finish);
        }

        if (operations.length === 0) {
            reject("All operations have finished");
        } else {
            connection.on("OperationStarted", finish);
            connection.on("OperationEnded", finish);
            connection.on("Log", finish);
        }
    });
}

//#endregion

async function next(): Promise<void> {
    if (history.position == history.snapshots.length - 1) {
        if (operations.length > 0) {
            connection.invoke("Advance");
            await nextEvent();
        }
    } else {
        goToHistory(history.position + 1);
    }
}

async function previous(): Promise<void> {
    // This is only async for symmetry with next, which needs to be async.
    if (history.position > 0) {
        goToHistory(history.position - 1);
    }
}

async function repeatUntil(step: () => Promise<void>, success: () => boolean): Promise<void> {
    const before = history.position;  // Make sure we're making progress each step.
    await step();
    if (history.position !== before && !success()) {
        await repeatUntil(step, success);
    }
}

function jump(event: Event): void {
    let operation: HTMLLIElement;
    if (event.target instanceof HTMLLIElement) {
        operation = event.target;
    } else if (event.target instanceof HTMLSpanElement && event.target.parentElement instanceof HTMLLIElement) {
        operation = event.target.parentElement;
    } else {
        return;
    }
    const position = history.snapshots.findIndex(snapshot => operation === snapshot.nextOperation);
    if (position !== -1) {
        goToHistory(position);
    }
}

function isOperationStart(): boolean {
    return history.snapshots[history.position].nextOperation !== null;
}

btnStepIn.addEventListener("click", async () => {
    await repeatUntil(next, isOperationStart);
    scrollToCurrentOperation();
});
btnStepOver.addEventListener("click", async () => {
    const level = getLevel(getCurrentOperation());
    await repeatUntil(next, () => isOperationStart() && getLevel(getCurrentOperation()) <= level);
    scrollToCurrentOperation();
});
btnPrevious.addEventListener("click", async () => {
    await repeatUntil(previous, isOperationStart);
    scrollToCurrentOperation();
});
olOperations.addEventListener("click", jump);
