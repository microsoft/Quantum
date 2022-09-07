---
page_type: sample
author: adrianleh
description: Numerical Integration with Quantum Amplitude Estimation, using the Azure Quantum service
ms.author: t-alehmann@microsoft.com
ms.date: 09/06/2021
languages:
- qsharp
- python
products:
- qdk
- azure-quantum
---

# Numerical Integration with Quantum Amplitude Estimation (QAE)

In this sample we will be using Quantum Amplitude Estimation to perform numerical integration on the function $f(x) = \sin^2(\pi x)$.

This sample is based on the work [arXiv:2005.07711](https:arxiv.org/abs/2005.07711) by Vazquez and Woerner.
We build QAE, optimize it, see the effects of the optimization and run on both the simulator and hardware.
This will allow us to the real-world effects of noise in NISQ machines.

In this sample we cover techniques of visualizing results and seeing noise on hardware in action.

This sample is a Q# jupyter notebook targeted at IonQ  machines.

## Q# with Jupyter Notebook

Make sure that you have followed the [Q# + Jupyter Notebook quickstart](https://docs.microsoft.com/azure/quantum/install-jupyter-qdk) for the Quantum Development Kit, and then start a new Jupyter Notebook session from the folder containing this sample:

```shell
cd qae-num-int
jupyter notebook
```

Once Jupyter starts, open the `QuantumAmplitudeEstimation.ipynb` notebook and follow the instructions there.

## Manifest

- [QuantumAmplitudeEstimation.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/qae-num-int/QuantumAmplitudeEstimation.ipynb): IQ# notebook for this sample targetting IonQ.