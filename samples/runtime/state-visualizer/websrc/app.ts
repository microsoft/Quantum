// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import "./css/main.css";
import * as signalR from "@aspnet/signalr";
import * as chart from "chart.js";
import { createSqore, Circuit, Operation } from "sqore";

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
const circuitContainer: HTMLElement = document.getElementById("circuit-container");
if (circuitContainer == null) throw new Error("circuit-container div not found.");

// Event handlers to visually signal to user that the gate can be zoomed in/out on key-press
document.addEventListener('keydown', (ev) => {
    if (ev.ctrlKey) {
        document.querySelectorAll('[data-zoom-in="true"]').forEach((el: HTMLElement) => {
            el.style.cursor = 'zoom-in';
        });
    } else if (ev.shiftKey) {
        document.querySelectorAll('[data-zoom-out="true"]').forEach((el: HTMLElement) => {
            el.style.cursor = 'zoom-out';
        });
    }
});
document.addEventListener('keyup', () => {
    document.querySelectorAll('.gate').forEach((el: HTMLElement) => {
        el.style.cursor = 'pointer';
    });
});

//#endregion

/**
 * Mapping from gate ID to operation and state (used in jumping to state).
 */
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

/**
 * Updates chart with new state for display.
 * @param state State to display.
 */
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

/**
 * Renders execution path as circuit in DOM.
 * @param executionPathStr Execution path as a JSON string.
 */
function onExecutionPath(executionPathStr: string) {
    const executionPath: Circuit = JSON.parse(executionPathStr);

    // Initialize gate registry
    fillGateRegistry(executionPath.operations[0], "0");

    // View operations 1 depth lower than outer operation
    if (executionPath.operations.length === 1 && executionPath.operations[0].children != null) {
        executionPath.operations = executionPath.operations[0].children;
    }

    // Render circuit to DOM
    renderCircuit(executionPath);

    // Set initial state to all 0's state
    const initialState: State = [{
        Real: 1,
        Imaginary: 0,
        Magnitude: 1,
        Phase: 0,
    }];
    updateChart(initialState);
}

/**
 * Depth-first traversal to fill gate registry and assign unique ID to operation
 * @param operation Operation to parse and add to gate registry.
 * @param id ID to assign to operation.
 */
function fillGateRegistry(operation: Operation, id: string) {
    if (operation.dataAttributes == null) operation.dataAttributes = {};
    operation.dataAttributes["id"] = id;
    operation.dataAttributes['zoom-out'] = 'false';
    const state: State = JSON.parse(operation.dataAttributes['state']);
    gateRegistry[id] = { operation, state };
    // Can remove state from attributes now
    delete operation.dataAttributes.state;
    operation.children?.forEach((childOp: Operation, i: number) => {
        fillGateRegistry(childOp, `${id}-${i}`);
        childOp.dataAttributes['zoom-out'] = 'true';
    });
    operation.dataAttributes['zoom-in'] = (operation.children != null).toString();
}

/**
 * Handles interacting with Sqore to generate the circuit visualization and inject into the DOM.
 * @param circuit Circuit for rendering to DOM.
 */
function renderCircuit(circuit: Circuit): void {
    // Add data attributes
    tagOperations(circuit);

    // Inject custom JS only if this is the first time rendering
    const injectScript: boolean = (displayedCircuit == null);
    // Render circuit visualization to DOM
    const svg: string = createSqore().compose(circuit).asSvg(injectScript);
    circuitContainer.innerHTML = svg;
    displayedCircuit = circuit;

    // Handle click events
    addGateClickHandlers();
}

/**
 * Adds data attributes to circuit operations.
 * @param circuit Circuit containing operations to tag.
 */
function tagOperations(circuit: Circuit): void {
    circuit.operations.forEach((op: Operation, i: number) => {
        if (op.dataAttributes == null) op.dataAttributes = {};
        // Add position in circuit
        op.dataAttributes.position = i.toString();
    });
}

/**
 * Adds onClick handlers to gates in circuit visualization to handle jumping and zoom in/out.
 */
function addGateClickHandlers(): void {
    document.querySelectorAll('.gate').forEach((gate) => {
        gate.addEventListener('click', (ev: MouseEvent) => {
            const id: string = gate.getAttribute('data-id');
            if (ev.ctrlKey) expandOperation(id);
            else if (ev.shiftKey) collapseOperation(id);
            else jumpToGate(gate);
        });
    });
}

/**
 * Jumps to target gate and displays the state at that point.
 * @param targetGate Target gate to jump to.
 */
function jumpToGate(targetGate: Element) {
    // Get state from targetGate metadata
    const id: string = targetGate.getAttribute('data-id');
    const position: number = Number(targetGate.getAttribute('data-position'));
    const state: State = gateRegistry[id].state;
    updateChart(state);

    // Colour gates
    document.querySelectorAll('.gate').forEach(gate => {
        const pos: number = Number(gate.getAttribute('data-position'));
        if (pos === position) gate.setAttribute("data-type", "selected");
        else if (pos < position) gate.setAttribute("data-type", "");
        else gate.setAttribute("data-type", "pending");
    });
}

/**
 * Handles expansion of operation with given ID.
 * @param id ID of operation to expand.
 */
function expandOperation(id: string) {
    let operations: Operation[] = displayedCircuit.operations;
    operations = operations.map(op => {
        if (op.dataAttributes == null) return op;
        const opId: string = op.dataAttributes["id"];
        if (opId === id && op.children != null) return op.children;
        return op;
    }).flat();
    displayedCircuit.operations = operations;

    renderCircuit(displayedCircuit);
}

/**
 * Handles collapse of operation with given ID to parent operation.
 * @param id ID of operation to collapse.
 */
function collapseOperation(id: string) {
    // Cannot collapse top-level operation
    if (id === "0") return;
    const parentId: string = id.match(/(.*)-\d/)[1];
    displayedCircuit.operations = displayedCircuit.operations
        .map(op => {
            if (op.dataAttributes == null) return op;
            const opId: string = op.dataAttributes["id"];
            // Replace with parent operation
            if (opId === id) return gateRegistry[parentId].operation;
            // If operation is a descendant, don't render
            if (opId.startsWith(parentId)) return null;
            return op;
        })
        .filter(op => op != null);
    renderCircuit(displayedCircuit);
}

//#endregion
