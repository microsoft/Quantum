import { Qubit } from "../executionPath";
import { RegisterType, RegisterMap, RegisterMetadata } from "../register";
import {
    leftPadding,
    startY,
    registerHeight,
    classicalRegHeight,
} from "../constants";

/**
 * `formatInputs` takes in an array of Qubits and outputs the SVG string of formatted
 * qubit wires and a mapping from register IDs to register metadata (for rendering).
 * 
 * @param qubits List of declared qubits.
 * 
 * @returns returns the SVG string of formatted qubit wires, a mapping from registers
 *          to y coord and total SVG height.
 */
const formatInputs = (qubits: Qubit[]): { qubitWires: string, registers: RegisterMap, svgHeight: number } => {
    const qubitWires: string[] = [];
    const registers: RegisterMap = {};

    let currY: number = startY;
    qubits.forEach(({ id, numChildren }) => {
        // Add qubit wire to list of qubit wires
        qubitWires.push(_qubitInput(currY));

        // Create qubit register
        registers[id] = { type: RegisterType.Qubit, y: currY };

        // If there are no attached classical registers, increment y by fixed register height
        if (numChildren == null || numChildren === 0) {
            currY += registerHeight;
            return;
        }

        // Increment current height by classical register height for attached classical registers
        currY += classicalRegHeight;

        // Add classical wires
        registers[id].children = Array.from(Array(numChildren), _ => {
            const clsReg: RegisterMetadata = { type: RegisterType.Classical, y: currY };
            currY += classicalRegHeight;
            return clsReg;
        });
    });

    return {
        qubitWires: qubitWires.join('\n'),
        registers,
        svgHeight: currY
    };
};

/**
 * Generate the SVG text component for the input qubit register.
 * 
 * @param y y coord of input wire to render in SVG.
 * 
 * @returns SVG text component for the input register.
 */
const _qubitInput = (y: number): string =>
    `<text x="${leftPadding}" y="${y}" dominant-baseline="middle" text-anchor="start">|0⟩</text>`;

export {
    formatInputs,
    _qubitInput,
};
