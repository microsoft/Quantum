---
page_type: sample
languages:
- qsharp
products:
- qdk
- azure-quantum
description: Iterative phase estimation calculating an inner product between two vectors.
urlFragment: iterative-phase-estimation
---

# Iterative Phase Estimation via the Cloud

This sample code and notebook was written by members of KPMG Quantum team in Australia. It aims to demonstrate expanded capabilities of Basic Measurement Feedback targets and makes use of bounded loops, classical function calls at run time, nested conditional if statements, mid circuit measurements and qubit reuse.

## Manifest
<!-- markdown-link-check-disable-next-line -->
- [iterative-phase-estimation.qs](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/iterative-phase-estimation/iterative-phase-estimation.qs): Q# sample code.
<!-- markdown-link-check-disable-next-line -->
- [iterative-phase-estimation.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/iterative-phase-estimation/iterative-phase-estimation.ipynb): Jupyter notebook.
<!-- markdown-link-check-disable-next-line -->
- [iterative-phase-estimation.csproj](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/iterative-phase-estimation/iterative-phase-estimation.csproj): CS Project file.

### Two Dimensional Inner Product Calculation Using Iterative Phase Estimation on Three Qubits

This notebook demonstrates an iterative phase estimation within Q#. It will use iterative phase estimation to calculate an inner product between two 2-dimensional vectors encoded on a target qubit and an ancilla qubit. An additional control qubit is also initialised which will be the only qubit used for measurement.

The circuit begins by encoding the pair of vectors on the target qubit and the ancilla qubit. It then applies an Oracle operator to the entire register, controlled off the control qubit (which is set up in the $\ket +$ state). The controlled Oracle operator generates a phase on the $\ket 1$ state of the control qubit. This can then be read by applying a H gate to the control qubit to make the phase observable when measuring.

## Encoding vectors

The vectors v and c are to be encoded onto the target qubit and the ancilla qubit. The vector $v = (cos(\frac{\theta_1}{2}),sin(\frac{\theta_1}{2}))$ can be represented by the quantum state $\ket v = cos(\frac{\theta_1}{2})\ket 0 + sin(\frac{\theta_1}{2})\ket 1$, similarly $c$ can be constructed using $\theta_2$.

A Y rotation applied to a target qubit in the $\ket 0$ state:

$$RY(\theta)\ket 0 = e^{iY\theta/2}\ket 0 = cos(\frac{\theta}{2})\ket 0 + sin(\frac{\theta}{2})\ket 1$$

**Note**: A factor of 2 is present here on theta. An application of a $RY(2\pi)$ gate on $\ket 0$ gives the state $-\ket 0$ and would encode the vector $(-1,0)$. This phase cannot be considered a global phase and removed as the entire register will be entangled.

The register of the target qubit and ancilla qubit is,

$$\ket  \Psi = \ket {\Psi_\text{Target qubit}}\ket {\Psi_\text{Ancilla qubit}}$$
The state to be created is on the target qubit and the ancilla qubit is,

$$\ket{\Psi}=\frac{1}{\sqrt{2}}(\ket{v}\ket{+}+\ket{c}\ket{-}),$$

which also takes the form,

$$\ket{\Psi} = \frac{1}{2}(\ket{v}+\ket{c})\ket{0}+\frac{1}{2}(\ket{v}-\ket{c})\ket{1}.$$

## The Oracle

An oracle G needs to be constructed such that it generates an eigenphase on the state encoded on the target qubit and the ancilla qubit. The construction of this oracle is unimportant to the demonstration within this notebook, but the operation it applies is,

$$G\ket \Psi = e^{2\pi i\phi} \ket \Psi.$$

where the inner product $\braket {v|c}$ is contained within the phase $\phi$, which is bound between [0,1]. When applied controlled on the control qubit which begins in that state $\ket{\Psi_\text{Control Qubit}} = \ket +$,

$$\begin{aligned}
    \text{Controlled }G \ket{\Psi_\text{Control Qubit}} \ket \Psi  & = \frac {1}{\sqrt{2}} (\ket 0 \ket \Psi + e^{2\pi i\phi}\ket 1 \ket \Psi )\\
    & =\frac {1}{\sqrt{2}} (\ket 0 + e^{2\pi i\phi}\ket 1) \ket \Psi
\end{aligned}$$

Now the control qubit contains the phase $\phi$ which relates to the inner product $\braket {v|c}$

$$\ket{\Psi_\text{Control Qubit}} = \frac {1}{\sqrt{2}} (\ket 0 + e^{2\pi i\phi}\ket 1)$$

## Iteration

Now for the iterative part of the circuit. For n measurements, consider that the phase can be represented as a binary value $\phi$, and that applying $2^n$ oracles makes the nth binary point of the phase observable (through simple binary multiplication, and modulus $2\pi$). The value of the control qubit can be readout, placed in a classical register and the qubit reset for use in the next iteration. The next iteration applies $2^{n-1}$ oracles, correcting phase on the control qubit dependent on the nth measurement. The state on the control qubit can be represented as,

$$ \ket {\Psi_{\text{Control Qubit}}} = \ket 0 + e^{2\pi i\phi}\ket 1 $$

where $\phi = 0.\phi_0\phi_1\phi_2\phi_3$...

Applying $2^n$ controlled oracles gives the state on the control qubit,

$$ G^{2^n}\ket {\Psi_{\text{Control Qubit}}} = \ket 0 + e^{2\pi i 0.\phi_n\phi_{n+1}\phi_{n+2}\phi_{n+3}...}\ket 1 $$

Consider that the phase has no terms deeper than $\phi_n$ (ie, terms $\phi_{n+1},\phi_{n+2}, \text{etc}$),

$$ G^{2^n}\ket {\Psi_{\text{Control Qubit}}} = \ket 0 + e^{2\pi i 0.\phi_n}\ket 1 $$

Now the value $\phi_n$ can be observed with a H gate and a measurement projecting along the Z axis. Resetting the control qubit and applying the oracle $2^{n-1}$ times,

$$ G^{2^{n-1}}\ket {\Psi_{\text{Control Qubit}}} = \ket 0 + e^{2\pi i 0.\phi_{n-1}\phi_n}\ket 1 $$

Using the previous measured value for $\phi_n$, the additional binary point can be rotated out.

$$ RZ(-2\pi \times 0.0\phi_n)G^{n-1}\ket {\Psi_{\text{Control Qubit}}} = \ket 0 + e^{2\pi i 0.\phi_{n-1}}\ket 1 $$

This process is iteratively applied for some bit precision n to obtain the phase $0.\phi_0\phi_1\phi_2...\phi_{n}$. The value is stored as a binary value $x = \phi_0\phi_1\phi_2...\phi_{n}$ as only integers are manipulatable at runtime currently.

As the readout tells nothing of either vector, only the inner product between them, the states on the target qubit and ancilla qubit remain in the same state throughout the process!

Finally to calculate the inner product from the measured value,

$$\braket {v|c} = -cos(2\pi x / 2^n)$$

where $x = \phi_0\phi_1\phi_2...\phi_{n}$. The denominator within the cosine function is to shift the binary point to match the original value $\phi$.

**Note**: For inner product that are not -1 or 1, the solutions are paired with a value difference of $2^{n-1}$. For example for n=3 measurements, the measured bit value of 2 would also have a pair solution of 6. Either of these values produce the same value of the inner product when input as the variable to the even function cosine (resulting in an inner product of 0 in this example).

**Note**: For inner product solutions between the discrete bit precision, a distribution of results will be produced based on where the inner product lies between the discrete bit value.

## Running using Azure CLI via VS Code

### Simulating iterative phase estimation

It is suggested that the SimulateInnerProduct is run first by placing "@EntryPoint()" before the operation SimulateInnerProduct and by using:

```powershell
    dotnet run
```

in the terminal before running on an Azure target. This version of the inner product operation will output additional information. This includes the manipulation of doubles of which the output is displayed in the terminal.

### Running on an Azure target

When running the job via the terminal using VS Code the following call should be made:

```powershell
az quantum job submit --target-id quantinuum.sim.h1-1e --target-capability AdaptiveExecution --shots 128 --job-name IterativePhaseEstimation
```

**Note**: The target requires a target execution profile that supports basic measurement feedback.

This will submit a job with the name "IterativePhaseEstimation". The circuit is approximately 0.4 EHQC each shot. The number of shots specified is 128, but this can be increased to reduce the variance of the result, up to some stable distribution. The total EHQCs for a job can be viewed within the Azure portal under "Job management". Selecting the desired job, the cost estimation can be viewed. It is not suggested to increase the number of measurements beyond 3 for running on Azure targets as the EHQCs can increase significantly. Be sure to place "@EntryPoint()" before the operation HardwareInnerProduct, not SimulateInnerProduct as this operation contains calls such as "Message" which is only used for printing to the terminal within VS Code. Job data can be accessed as normal through the Azure portal or via the terminal using

```powershell
az quantum job output -j JOB_ID -o table
```

replacing "JOB_ID" with the job id. The results show a solution in the state with the majority population. The final inner product from the integer results can be calculated by $\braket {v|c} = -cos(2\pi x / 2^n)$, where n is the number of measurements specificed in the job.

**Note**: Choosing input parameters which only has one solution state (inner produces of -1 or 1) are ideal for visibility at a low number of shots.
