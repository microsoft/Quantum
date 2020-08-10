import { GateType } from "./constants";

/**
 * Metadata used to store information pertaining to a given
 * operation for rendering its corresponding SVG.
 */
export interface Metadata {
    /** Gate type. */
    type: GateType;
    /** Centre x coord for gate position. */
    x: number;
    /** Array of y coords of control registers. */
    controlsY: number[];
    /** Array of y coords of target registers. */
    targetsY: number[];
    /** Gate label. */
    label: string;
    /** Gate arguments as string. */
    displayArgs?: string,
    /** Gate width. */
    width: number;
    /** Classically-controlled gates.
     *  - children[0]: gates when classical control bit is 0.
     *  - children[1]: gates when classical control bit is 1.
    */
    children?: Metadata[][];
    /** HTML element class for interactivity. */
    htmlClass?: string;
};
