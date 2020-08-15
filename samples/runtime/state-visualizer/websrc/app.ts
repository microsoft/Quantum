// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import "./css/main.css";
import * as signalR from "@aspnet/signalr";
import * as chart from "chart.js";
import { circuitToSvg, Circuit, Operation } from "sqore";

//#region Serialization contract

type State = {
    Real: number,
    Imaginary: number,
    Magnitude: number,
    Phase: number
}[];

//#endregion

//#region HTML elements

const canvas: HTMLCanvasElement = document.querySelector("#chartCanvas");
const chartContext = canvas.getContext("2d");

//#endregion

type GateRegistry = {
    [id: string]: {
        operation: Operation,
        state: State,
    }
};

const gateRegistry: GateRegistry = {};
let displayedCircuit: Circuit = null;

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
    let real = state.map(amplitude => amplitude.Real);
    let imag = state.map(amplitude => amplitude.Imaginary);
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

//#region SignalR hub connection

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/events")
    .build();

connection.start().catch(err => document.write(err));
connection.on("ExecutionPath", onExecutionPath);

function onExecutionPath(executionPathStr: string) {
    const executionPath: Circuit = JSON.parse(executionPathStr);

    // Initialize gate registry
    fillGateRegistry(executionPath.operations[0], "0");

    // Render circuit to DOM
    renderCircuit(executionPath);
}

// Depth-first traversal to fill gate registry and assign unique ID to operation
function fillGateRegistry(operation: Operation, id: string) {
    if (operation.customMetadata == null) operation.customMetadata = {};
    operation.customMetadata["id"] = id;
    const { state } = operation.customMetadata as { state: State };
    gateRegistry[id] = { operation, state };
    // Can remove state from metadata now
    delete operation.customMetadata.state;
    operation.children?.forEach((childOp, i) => fillGateRegistry(childOp, `${id}-${i}`));
}

function renderCircuit(circuit: Circuit) {
    // Add metadata
    parseOperations(circuit);

    // Render circuit visualization to DOM
    const svg: string = circuitToSvg(circuit);
    const container: HTMLElement = document.getElementById("circuit-container");
    if (container == null) throw new Error("circuit-container div not found.");
    container.innerHTML = svg;
    displayedCircuit = circuit;

    // Handle click events
    addGateClickHandlers();
}

function parseOperations(circuit: Circuit) {
    circuit.operations.forEach((op, i) => {
        if (op.customMetadata == null) op.customMetadata = {};
        // Add position in circuit
        op.customMetadata.position = i;
    });
}

function addGateClickHandlers(): void {
    document.querySelectorAll('.gate').forEach((gate) => {
        // Jump to clicked gate
        gate.addEventListener('click', () => jumpToGate(gate));

        // Zoom in on clicked gate
        gate.addEventListener('dblclick', (ev: MouseEvent) => {
            const { id }: { id: string } = JSON.parse(gate.getAttribute('data-metadata'));
            if (ev.ctrlKey) collapseOperation(displayedCircuit, id);
            else expandOperation(displayedCircuit, id);
        });
    });
}

function jumpToGate(gate: Element) {
    // Get state from gate metadata
    const { id, position }: { id: string, position: number } = JSON.parse(gate.getAttribute('data-metadata'));
    const state: State = gateRegistry[id].state;
    updateChart(state);

    // Colour gates
    document.querySelectorAll('.gate').forEach(gate => {
        const gateMetadata: { position: number } = JSON.parse(gate.getAttribute('data-metadata'));
        const pos: number = gateMetadata.position;
        if (pos === position) gate.setAttribute("data-type", "selected");
        else if (pos < position) gate.setAttribute("data-type", "");
        else gate.setAttribute("data-type", "pending");
    });
}

function expandOperation(circuit: Circuit, id: string) {
    let operations: Operation[] = circuit.operations;
    operations = operations.map(op => {
        if (op.customMetadata == null) return op;
        const opId: string = op.customMetadata["id"] as string;
        if (opId === id && op.children != null) return op.children;
        return op;
    }).flat();
    circuit.operations = operations;

    renderCircuit(circuit);
}

function collapseOperation(circuit: Circuit, id: string) {
    // Cannot collapse top-level operation
    if (id === "0") return;
    const parentId: string = id.match(/(.*)-\d/)[1];
    circuit.operations = circuit.operations
        .map(op => {
            if (op.customMetadata == null) return op;
            const opId: string = op.customMetadata["id"] as string;
            // Replace with parent operation
            if (opId === id) return gateRegistry[parentId].operation;
            // If operation is a descendant, don't render
            if (opId.startsWith(parentId)) return null;
            return op;
        })
        .filter(op => op != null);
    renderCircuit(circuit);
}

//#endregion
