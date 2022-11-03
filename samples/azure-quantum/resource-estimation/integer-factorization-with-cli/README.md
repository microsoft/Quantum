# Resource estimation with Q# and VS Code

👋 Welcome to Azure Quantum Resources Estimation. In this Q# project we will
guide you how to estimate the costs of integer factorization on a fault-tolerant
quantum computer. 

## Azure login and workspace setup

The following steps only need to be done when starting to work with this
project.

Log into Azure using the following command (this will open a browser window):

```
az login
```

Set your subscription ID (you can find the subscription ID under _Essentials_ on
the _Overview_ page of your Azure Quantum Workspace):

```
az account set -s <subscription-id>
```

Set your resource group, workspace name, and location (you also find these under
_Essentials_ on the _Overview_ page of your Azure Quantum Workspace; the name
can be found on the top left of the browser window):

```
az quantum workspace set -g <resource-group> -w <workspace-name> -l <location> -o table
```

## Submit a job to Azure Quantum and read out the result

Submit a job using the following command

```
az quantum job submit --target-id microsoft.estimator -o json --query id
```

The output will the job ID.  Copy the ID and request the output of the job with:

```
az quantum job output -j <job-id> -o table
```

Let's next change the inputs to our job. We have prepared some sample
configuration in the file `jobParams.json`. You can pass them to the
`--job-params` argument like this:

```
az quantum job submit --target-id microsoft.estimator -o json --query id --job-params "@jobParams.json"
```

Again you can inspect the table with

```
az quantum job output -j <job-id> -o table
```

### ℹ️ Customize job input parameters

Please refer to the [Azure Quantum documentation](https://learn.microsoft.com/en-us/azure/quantum/overview-resources-estimator?tabs=tabid-qsharp-vscode) for more information on job input parameters.

## Caching

This sample makes use of _resource estimation caching_, a dedicated technique
for Azure Quantum Resource Estimator to reduce execution time.  Inside the
implementation of `EstimateFrequency` you find the code block

```qsharp
if BeginCaching(1) {
    Controlled oracle([c], (1 <<< idx, eigenstateRegisterLE!));
    EndCaching(1);
}
```

The two special operations `BeginCaching` and `EndCaching` both take as input an
id (here 1), which should be unique for every code block that should be cached.
`BeginCaching` should be used as a condition to an if-block that will contain
the block to be cached.  When `BeginCaching` is called for the first time, it
will return true and record all resources until `EndCaching` is called for the
same id.  `EndCaching` should be placed at the end of the condition, and it will
store the cached resources in a dictionary with the id as a key.  All subsequent
times that `BeginCaching` is called with an id that is already cached, the
cached resources will be added to the the existing ones, instead of executing
the code again.

Note that no verification is taking place that checks whether the resources are
actually the same in every iteration.  In fact, in this factorization sample,
the resources are not precisely the same, but similar, such that the improvement
in runtime is a good trade-off.
