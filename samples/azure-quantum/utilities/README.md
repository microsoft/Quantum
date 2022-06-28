---
page_type: sample
author: anraman
description: Connect to data sources such as Azure Blob Storage using Azure Quantum hosted notebooks
ms.author: anraman@microsoft.com
ms.date: 06/28/2022
languages:
- python
products:
- blob-storage
- azure-quantum
---

# Data management sample

This sample shows you how to connect and use Azure Quantum with external datasources such as Azure Blob Storage. This sample is implemented as a Jupyter Notebook, which can be run locally or through the Azure Quantum hosted notebooks experience.

## Prerequisites

- Storage Account

You must have a Azure Storage account deployed to use Blob Storage for your data. If you are accessing this sample through Azure Quantum hosted notebooks, you should already have a Storage account set up for your [Quantum Workspace](https://docs.microsoft.com/azure/quantum/how-to-create-workspace?tabs=tabid-quick).

You can find details for this storage account by navigating to your Azure Quantum Workspace in the portal - it is shown in the 'Essentials' section at the top - if you click the name of the storage account it will take you to view it in the portal.

If you wish to use a different storage account, you can absolutely do so. More information on setting up a storage account can be found [here](https://docs.microsoft.com/azure/storage/common/storage-account-create?tabs=azure-portal).

## Manifest

- [storage-data-management.ipynb](https://github.com/microsoft/quantum/blob/main/samples/azure-quantum/utilities/storage-data-management.ipynb): Jupyter Notebook for this sample.
