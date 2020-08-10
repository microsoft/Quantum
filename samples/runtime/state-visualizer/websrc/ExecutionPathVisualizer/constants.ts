/**
 * Enum for the various gate operations handled.
 */
export enum GateType {
    /** Measurement gate. */
    Measure,
    /** CNOT gate. */
    Cnot,
    /** SWAP gate. */
    Swap,
    /** Single/multi qubit unitary gate. */
    Unitary,
    /** Single/multi controlled unitary gate. */
    ControlledUnitary,
    /** Nested group of classically-controlled gates. */
    ClassicalControlled,
    /** Invalid gate. */
    Invalid
};

// Display attributes
/** Left padding of SVG. */
export const leftPadding: number = 20;
/** x coordinate for first operation on each register. */
export const startX: number = 80;
/** y coordinate of first register. */
export const startY: number = 40;
/** Minimum width of each gate. */
export const minGateWidth: number = 40;
/** Height of each gate. */
export const gateHeight: number = 40;
/** Padding on each side of gate. */
export const gatePadding: number = 10;
/** Padding on each side of gate label. */
export const labelPadding: number = 10;
/** Height between each qubit register. */
export const registerHeight: number = gateHeight + gatePadding * 2;
/** Height between classical registers. */
export const classicalRegHeight: number = gateHeight;
/** Classical box inner padding. */
export const classicalBoxPadding: number = 15;
/** Additional offset for control button. */
export const controlBtnOffset: number = 40;
/** Control button radius. */
export const controlBtnRadius: number = 15;
/** Default font size for gate labels. */
export const labelFontSize: number = 14;
/** Default font size for gate arguments. */
export const argsFontSize: number = 12;
/** Starting x coord for each register wire. */
export const regLineStart: number = 40;
