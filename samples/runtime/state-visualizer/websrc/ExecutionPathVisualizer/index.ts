import { formatInputs } from "./formatters/inputFormatter";
import { formatGates } from "./formatters/gateFormatter";
import { formatRegisters } from "./formatters/registerFormatter";
import { processOperations } from "./process";
import { ExecutionPath } from "./executionPath";
import { Metadata } from "./metadata";
import { GateType } from "./constants";

const script = `
<script type="text/JavaScript">
    function toggleClassicalBtn(cls) {
        const textSvg = document.querySelector(\`.\${cls} text\`);
        const group = document.querySelector(\`.\${cls}-group\`);
        const currValue = textSvg.childNodes[0].nodeValue;
        const zeroGates = document.querySelector(\`.\${cls}-zero\`);
        const oneGates = document.querySelector(\`.\${cls}-one\`);
        switch (currValue) {
            case '?':
                textSvg.childNodes[0].nodeValue = '1';
                group.classList.remove('cls-control-unknown');
                group.classList.add('cls-control-one');
                break;
            case '1':
                textSvg.childNodes[0].nodeValue = '0';
                group.classList.remove('cls-control-one');
                group.classList.add('cls-control-zero');
                oneGates.classList.toggle('hidden');
                zeroGates.classList.toggle('hidden');
                break;
            case '0':
                textSvg.childNodes[0].nodeValue = '?';
                group.classList.remove('cls-control-zero');
                group.classList.add('cls-control-unknown');
                zeroGates.classList.toggle('hidden');
                oneGates.classList.toggle('hidden');
                break;
        }
    }
</script>
`;

const style = `
<style>
    .hidden {
        display: none;
    }
    .cls-control-unknown {
        opacity: 0.25;
    }
    <!-- Gate outline -->
    .cls-control-one rect,
    .cls-control-one line,
    .cls-control-one circle {
        stroke: #4059bd;
        stroke-width: 1.3;
    }
    .cls-control-zero rect,
    .cls-control-zero line,
    .cls-control-zero circle {
        stroke: #c40000;
        stroke-width: 1.3;
    }
    <!-- Gate label -->
    .cls-control-one text {
        fill: #4059bd;
    }
    .cls-control-zero text {
        fill: #c40000;
    }
    <!-- Control button -->
    .cls-control-btn {
        cursor: pointer;
    }
    .cls-control-unknown .cls-control-btn {
        fill: #e5e5e5;
    }
    .cls-control-one .cls-control-btn {
        fill: #4059bd;
    }
    .cls-control-zero .cls-control-btn {
        fill: #c40000;
    }
    <!-- Control button text -->
    .cls-control-unknown .cls-control-text {
        fill: black;
        stroke: none;
    }
    .cls-control-one .cls-control-text,
    .cls-control-zero .cls-control-text {
        fill: white;
        stroke: none;
    }
</style>
`;

/**
 * Converts JSON representing an execution path of a Q# program given by the simulator and returns its HTML visualization.
 * 
 * @param json JSON received from simulator.
 * 
 * @returns HTML representation of circuit.
 */
export const executionPathToHtml = (json: ExecutionPath): string => {
    const { qubits, operations } = json;
    const { qubitWires, registers, svgHeight } = formatInputs(qubits);
    const { metadataList, svgWidth } = processOperations(operations, registers);
    const formattedGates: string = formatGates(metadataList);
    const measureGates: Metadata[] = metadataList.filter(({ type }) => type === GateType.Measure);
    const formattedRegs: string = formatRegisters(registers, measureGates, svgWidth);
    return `<html>
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="${svgWidth}" height="${svgHeight}">
        ${script}
        ${style}
        ${qubitWires}
        ${formattedRegs}
        ${formattedGates}
    </svg>
</html>`;
};
