---
page_type: sample
description: "This sample shows you how to connect to data sources such as Azure Blob Storage from within an Azure Quantum Jupyter Notebook"
languages:
- python
products:
- blob-storage
- azure-quantum
- qdk
---

# Data management sample

This sample shows you how to connect and use Azure Quantum with external datasources such as [Azure Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-blobs-introduction). This sample is implemented as a Jupyter Notebook, which can be run locally or through the Azure Quantum hosted notebooks experience.

This sample is available as part of the Azure Quantum notebook samples gallery in the Azure Portal. For an example of how to run these notebooks in Azure, see [this getting started guide](https://docs.microsoft.com/azure/quantum/get-started-jupyter-notebook?tabs=tabid-ionq).

## Prerequisites

- [Azure Quantum Workspace](https://docs.microsoft.com/azure/quantum/how-to-create-workspace?tabs=tabid-quick)

You must have an Azure Quantum Workspace deployed to use this sample, as it connects to the Azure Storage account associated with your Workspace. This Storage account is automatically created when you create a new Azure Quantum Workspace.

You can find details for this storage account by navigating to your Azure Quantum Workspace in the portal - it is shown in the 'Essentials' section at the top - if you click the name of the storage account it will take you to view it in the portal.

## Manifest

- [storage-data-management.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/utilities/storage-data-management.ipynb): Jupyter Notebook for this sample.
