import { Register } from "./register";

/**
 * Structure of JSON representation of the execution path of a Q# operation.
 */
export interface ExecutionPath {
    /** Array of qubit resources. */
    qubits: Qubit[];
    operations: Operation[];
};

/**
 * Represents a unique qubit resource bit.
 */
export interface Qubit {
    /** Qubit ID. */
    id: number;
    /** Number of classical registers attached to quantum register. */
    numChildren?: number;
};

/**
 * Represents an operation and the registers it acts on.
 */
export interface Operation {
    /** Gate label. */
    gate: string;
    /** Formatted gate arguments to be displayed. */
    displayArgs?: string,
    /** Classically-controlled gates.
     *  - children[0]: gates when classical control bit is 0.
     *  - children[1]: gates when classical control bit is 1.
    */
    children?: Operation[][];
    /** Whether gate is a measurement operation. */
    isMeasurement: boolean;
    /** Whether gate is a controlled operation. */
    isControlled: boolean;
    /** Whether gate is an adjoint operation. */
    isAdjoint: boolean;
    /** Control registers the gate acts on. */
    controls: Register[];
    /** Target registers the gate acts on. */
    targets: Register[];
};
