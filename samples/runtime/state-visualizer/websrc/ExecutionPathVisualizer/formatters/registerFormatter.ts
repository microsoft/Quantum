import { RegisterMap } from "../register";
import { regLineStart, GateType } from "../constants";
import { Metadata } from "../metadata";
import { line } from "./formatUtils";

/**
 * Generate the SVG representation of the qubit register wires in `registers` and the classical wires
 * stemming from each measurement gate.
 * 
 * @param registers    Map from register IDs to register metadata.
 * @param measureGates Array of measurement gates metadata.
 * @param endX         End x coord.
 * 
 * @returns SVG representation of register wires.
 */
const formatRegisters = (registers: RegisterMap, measureGates: Metadata[], endX: number): string => {
    const formattedRegs: string[] = [];
    // Render qubit wires
    for (const qId in registers) {
        formattedRegs.push(_qubitRegister(Number(qId), endX, registers[qId].y));
    }
    // Render classical wires
    measureGates.forEach(({ type, x, targetsY, controlsY }) => {
        if (type !== GateType.Measure) return;
        const gateY: number = controlsY[0];
        targetsY.forEach(y => {
            formattedRegs.push(_classicalRegister(x, gateY, endX, y));
        });
    });
    return formattedRegs.join('\n');
};

/**
 * Generates the SVG representation of a classical register.
 * 
 * @param startX Start x coord.
 * @param gateY  y coord of measurement gate.
 * @param endX   End x coord.
 * @param wireY  y coord of wire.
 * 
 * @returns SVG representation of the given classical register.
 */
const _classicalRegister = (startX: number, gateY: number, endX: number, wireY: number): string => {
    const wirePadding: number = 1;
    // Draw vertical lines
    const vLine1: string = line(startX + wirePadding, gateY, startX + wirePadding, wireY - wirePadding, 0.5);
    const vLine2: string = line(startX - wirePadding, gateY, startX - wirePadding, wireY + wirePadding, 0.5);
    // Draw horizontal lines
    const hLine1: string = line(startX + wirePadding, wireY - wirePadding, endX, wireY - wirePadding, 0.5);
    const hLine2: string = line(startX - wirePadding, wireY + wirePadding, endX, wireY + wirePadding, 0.5);
    const svg: string = [vLine1, vLine2, hLine1, hLine2].join('\n');
    return svg;
};

/**
 * Generates the SVG representation of a qubit register.
 * 
 * @param qId         Qubit register index.
 * @param endX        End x coord.
 * @param y           y coord of wire.
 * @param labelOffset y offset for wire label.
 * 
 * @returns SVG representation of the given qubit register.
 */
const _qubitRegister = (qId: number, endX: number, y: number, labelOffset: number = 16): string => {
    const labelY: number = y - labelOffset;
    const wire: string = line(regLineStart, y, endX, y);
    const label: string = `<text x="${regLineStart}" y="${labelY}" dominant-baseline="hanging" text-anchor="start" font-size="75%">q${qId}</text>`;
    const svg: string = [wire, label].join('\n');
    return svg;
};

export {
    formatRegisters,
    _classicalRegister,
    _qubitRegister,
};
