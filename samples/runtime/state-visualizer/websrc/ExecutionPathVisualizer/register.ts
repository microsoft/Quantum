/**
 * Type of register.
 */
export enum RegisterType {
    Qubit,
    Classical
};

/**
 * Represents a register resource.
 */
export interface Register {
    /** Type of register. */
    type: RegisterType;
    /** Qubit register ID. */
    qId: number;
    /** Classical register ID (if classical register). */
    cId?: number;
};

export interface RegisterMetadata {
    /** Type of register. */
    type: RegisterType;
    /** y coord of register */
    y: number;
    /** Nested classical registers attached to quantum register. */
    children?: RegisterMetadata[];
};

export interface RegisterMap {
    [id: number]: RegisterMetadata
};
