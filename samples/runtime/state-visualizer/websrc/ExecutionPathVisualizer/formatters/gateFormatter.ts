import { Metadata } from "../metadata";
import {
    GateType,
    minGateWidth,
    gateHeight,
    registerHeight,
    labelFontSize,
    argsFontSize,
    controlBtnRadius,
    controlBtnOffset,
    classicalBoxPadding,
    classicalRegHeight,
} from "../constants";
import {
    group,
    controlDot,
    line,
    box,
    text,
    arc,
    dashedLine,
    dashedBox
} from "./formatUtils";

/**
 * Given an array of operations (in metadata format), return the SVG representation.
 * 
 * @param opsMetadata Array of Metadata representation of operations.
 * 
 * @returns SVG representation of operations.
 */
const formatGates = (opsMetadata: Metadata[]): string => {
    const formattedGates: string[] = opsMetadata.map(_formatGate);
    return formattedGates.flat().join('\n');
};

/**
 * Takes in an operation's metadata and formats it into SVG.
 * 
 * @param metadata Metadata object representation of gate.
 * 
 * @returns SVG representation of gate.
 */
const _formatGate = (metadata: Metadata): string => {
    const { type, x, controlsY, targetsY, label, displayArgs, width } = metadata;
    switch (type) {
        case GateType.Measure:
            return _measure(x, controlsY[0], targetsY[0]);
        case GateType.Unitary:
            return _unitary(label, x, targetsY, width, displayArgs);
        case GateType.Swap:
            if (controlsY.length > 0) return _controlledGate(metadata);
            else return _swap(x, targetsY);
        case GateType.Cnot:
        case GateType.ControlledUnitary:
            return _controlledGate(metadata);
        case GateType.ClassicalControlled:
            return _classicalControlled(metadata);
        default:
            throw new Error(`ERROR: unknown gate (${label}) of type ${type}.`);
    }
};

/**
 * Creates a measurement gate at the x position, where qy and cy are
 * the y coords of the qubit register and classical register, respectively.
 * 
 * @param x  x coord of measurement gate.
 * @param qy y coord of qubit register.
 * @param cy y coord of classical register.
 * 
 * @returns SVG representation of measurement gate.
 */
const _measure = (x: number, qy: number, cy: number): string => {
    x -= minGateWidth / 2;
    const width: number = minGateWidth, height = gateHeight;
    // Draw measurement box
    const mBox: string = box(x, qy - height / 2, width, height);
    const mArc: string = arc(x + 5, qy + 2, width / 2 - 5, height / 2 - 8);
    const meter: string = line(x + width / 2, qy + 8, x + width - 8, qy - height / 2 + 8);
    const svg: string = group(mBox, mArc, meter);
    return svg;
};

/**
 * Creates the SVG for a unitary gate on an arbitrary number of qubits.
 * 
 * @param label            Gate label.
 * @param x                x coord of gate.
 * @param y                Array of y coords of registers acted upon by gate.
 * @param width            Width of gate.
 * @param displayArgs           Arguments passed in to gate.
 * @param renderDashedLine If true, draw dashed lines between non-adjacent unitaries.
 * 
 * @returns SVG representation of unitary gate.
 */
const _unitary = (label: string, x: number, y: number[], width: number, displayArgs?: string, renderDashedLine: boolean = true): string => {
    if (y.length === 0) return "";

    // Sort y in ascending order
    y.sort((y1, y2) => y1 - y2);

    // Group adjacent registers
    let prevY: number = y[0];
    const regGroups: number[][] = y.reduce((groups: number[][], currY: number) => {
        // Registers are defined to be adjacent if they differ by registerHeight in their y coord
        // NOTE: This method of group registers by height difference might break if we want to add
        // registers with variable heights.
        if (groups.length === 0 || currY - prevY > registerHeight) groups.push([currY]);
        else groups[groups.length - 1].push(currY);
        prevY = currY;
        return groups;
    }, []);

    // Render each group as a separate unitary boxes
    const unitaryBoxes: string[] = regGroups.map((group: number[]) => {
        const maxY: number = group[group.length - 1], minY: number = group[0];
        const height: number = maxY - minY + gateHeight;
        return _unitaryBox(label, x, minY, width, height, displayArgs);
    });

    // Draw dashed line between disconnected unitaries
    if (renderDashedLine && unitaryBoxes.length > 1) {
        const maxY: number = y[y.length - 1], minY: number = y[0];
        const vertLine: string = dashedLine(x, minY, x, maxY);
        return [vertLine, ...unitaryBoxes].join('\n');
    } else return unitaryBoxes.join('\n');
};

/**
 * Generates SVG representation of the boxed unitary gate symbol.
 * 
 * @param label  Label for unitary operation.
 * @param x      x coord of gate.
 * @param y      y coord of gate.
 * @param width  Width of gate.
 * @param height Height of gate.
 * @param displayArgs Arguments passed in to gate.
 * 
 * @returns SVG representation of unitary box.
 */
const _unitaryBox = (label: string, x: number, y: number, width: number, height: number = gateHeight, displayArgs?: string): string => {
    y -= gateHeight / 2;
    const uBox: string = box(x - width / 2, y, width, height);
    const labelY = y + height / 2 - ((displayArgs == null) ? 0 : 7);
    const labelText: string = text(label, x, labelY);
    const elems = [uBox, labelText];
    if (displayArgs != null) {
        const argStrY = y + height / 2 + 8;
        const argText: string = text(displayArgs, x, argStrY, argsFontSize);
        elems.push(argText);
    }
    const svg: string = group(elems);
    return svg;
};

/**
 * Creates the SVG for a SWAP gate on y coords given by targetsY.
 * 
 * @param x          Centre x coord of SWAP gate.
 * @param targetsY   y coords of target registers.
 * 
 * @returns SVG representation of SWAP gate.
 */
const _swap = (x: number, targetsY: number[]): string => {
    // Get SVGs of crosses
    const crosses: string[] = targetsY.map(y => _cross(x, y));
    const vertLine: string = line(x, targetsY[0], x, targetsY[1]);
    const svg: string = group(crosses, vertLine);
    return svg;
};

/**
 * Generates cross for display in SWAP gate.
 * 
 * @param x x coord of gate.
 * @param y y coord of gate.
 * 
 * @returns SVG representation for cross.
 */
const _cross = (x: number, y: number): string => {
    const radius: number = 8;
    const line1: string = line(x - radius, y - radius, x + radius, y + radius);
    const line2: string = line(x - radius, y + radius, x + radius, y - radius);
    return [line1, line2].join('\n');
};

/**
 * Produces the SVG representation of a controlled gate on multiple qubits.
 * 
 * @param metadata Metadata of controlled gate.
 * 
 * @returns SVG representation of controlled gate.
 */
const _controlledGate = (metadata: Metadata): string => {
    const targetGateSvgs: string[] = [];
    const { type, x, controlsY, targetsY, label, displayArgs, width } = metadata;
    // Get SVG for target gates
    switch (type) {
        case GateType.Cnot:
            targetsY.forEach(y => targetGateSvgs.push(_oplus(x, y)));
            break;
        case GateType.Swap:
            targetsY.forEach(y => targetGateSvgs.push(_cross(x, y)));
            break;
        case GateType.ControlledUnitary:
            targetGateSvgs.push(_unitary(label, x, targetsY, width, displayArgs, false));
            break;
        default:
            throw new Error(`ERROR: Unrecognized gate: ${label} of type ${type}`);
    }
    // Get SVGs for control dots
    const controlledDotsSvg: string[] = controlsY.map(y => controlDot(x, y));
    // Create control lines
    const maxY: number = Math.max(...controlsY, ...targetsY);
    const minY: number = Math.min(...controlsY, ...targetsY);
    const vertLine: string = line(x, minY, x, maxY);
    const svg: string = group(vertLine, controlledDotsSvg, targetGateSvgs);
    return svg;
};

/**
 * Generates $\oplus$ symbol for display in CNOT gate.
 * 
 * @param x x coordinate of gate.
 * @param y y coordinate of gate.
 * @param r radius of circle.
 * 
 * @returns SVG representation of $\oplus$ symbol.
 */
const _oplus = (x: number, y: number, r: number = 15): string => {
    const circle: string = `<circle cx="${x}" cy="${y}" r="${r}" stroke="black" fill="white" stroke-width="1"></circle>`;
    const vertLine: string = line(x, y - r, x, y + r);
    const horLine: string = line(x - r, y, x + r, y);
    const svg: string = group(circle, vertLine, horLine);
    return svg;
}

/**
 * Generates the SVG for a classically controlled group of oeprations.
 * 
 * @param metadata Metadata representation of gate.
 * @param padding  Padding within dashed box.
 * 
 * @returns SVG representation of gate.
 */
const _classicalControlled = (metadata: Metadata, padding: number = classicalBoxPadding): string => {
    let { x, controlsY, targetsY, width, children, htmlClass } = metadata;

    const controlY = controlsY[0];
    if (htmlClass == null) htmlClass = 'cls-control';

    // Get SVG for gates controlled on 0 and make them hidden initially
    let childrenZero: string = (children != null) ? formatGates(children[0]) : '';
    childrenZero = `<g class="${htmlClass}-zero hidden">\r\n${childrenZero}</g>`;

    // Get SVG for gates controlled on 1
    let childrenOne: string = (children != null) ? formatGates(children[1]) : '';
    childrenOne = `<g class="${htmlClass}-one">\r\n${childrenOne}</g>`;

    // Draw control button and attached dashed line to dashed box
    const controlCircleX: number = x + controlBtnRadius;
    const controlCircle: string = _controlCircle(controlCircleX, controlY, htmlClass);
    const lineY1: number = controlY + controlBtnRadius, lineY2: number = controlY + classicalRegHeight / 2;
    const vertLine: string = dashedLine(controlCircleX, lineY1, controlCircleX, lineY2);
    x += controlBtnOffset;
    const horLine: string = dashedLine(controlCircleX, lineY2, x, lineY2);

    width = width - controlBtnOffset + (padding - classicalBoxPadding) * 2;
    x += classicalBoxPadding - padding;
    const y: number = targetsY[0] - gateHeight / 2 - padding;
    const height: number = targetsY[1] - targetsY[0] + gateHeight + padding * 2;

    // Draw dashed box around children gates
    const box: string = dashedBox(x, y, width, height);

    // Display controlled operation in initial "unknown" state
    const svg: string = group(`<g class="${htmlClass}-group cls-control-unknown">`, horLine, vertLine,
        controlCircle, childrenZero, childrenOne, box, '</g>');

    return svg;
};

/**
 * Generates the SVG representation of the control circle on a classical register with interactivity support
 * for toggling between bit values (unknown, 1, and 0).
 * 
 * @param x   x coord.
 * @param y   y coord.
 * @param cls Class name.
 * @param r   Radius of circle.
 * 
 * @returns SVG representation of control circle.
 */
const _controlCircle = (x: number, y: number, cls: string, r: number = controlBtnRadius): string =>
    `<g class="cls-control-btn ${cls}" onClick="toggleClassicalBtn('${cls}')">
<circle class="${cls}" cx="${x}" cy="${y}" r="${r}" stroke="black" stroke-width="1"></circle>
<text class="${cls} cls-control-text" font-size="${labelFontSize}" font-family="Arial" x="${x}" y="${y}" dominant-baseline="middle" text-anchor="middle" fill="black">?</text>
</g>`;

export {
    formatGates,
    _formatGate,
    _measure,
    _unitary,
    _swap,
    _controlledGate,
    _classicalControlled,
};