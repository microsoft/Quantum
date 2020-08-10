import { Metadata } from './metadata';
import {
    GateType,
    minGateWidth,
    labelPadding,
    labelFontSize,
    argsFontSize,
} from './constants';

/**
 * Calculate the width of a gate, given its metadata.
 * 
 * @param metadata Metadata of a given gate.
 * 
 * @returns Width of given gate (in pixels).
 */
const getGateWidth = ({ type, label, displayArgs, width }: Metadata): number => {
    switch (type) {
        case GateType.ClassicalControlled:
            // Already computed before.
            return width;
        case GateType.Measure:
        case GateType.Cnot:
        case GateType.Swap:
            return minGateWidth;
        default:
            const labelWidth = _getStringWidth(label);
            const argsWidth = (displayArgs != null) ? _getStringWidth(displayArgs, argsFontSize) : 0;
            const textWidth = Math.max(labelWidth, argsWidth) + labelPadding * 2;
            return Math.max(minGateWidth, textWidth);
    }
};

/**
 * Get the width of a string with font-size `fontSize` and font-family Arial.
 * 
 * @param text     Input string.
 * @param fontSize Font size of `text`. 
 * 
 * @returns Pixel width of given string.
 */
const _getStringWidth = (text: string, fontSize: number = labelFontSize): number => {
    var canvas: HTMLCanvasElement = document.createElement("canvas");
    var context: CanvasRenderingContext2D | null = canvas.getContext("2d");
    if (context == null) throw new Error("Null canvas");
    
    context.font = `${fontSize}px Arial`;
    var metrics: TextMetrics = context.measureText(text);
    return metrics.width;
};

export {
    getGateWidth,
    _getStringWidth,
};
