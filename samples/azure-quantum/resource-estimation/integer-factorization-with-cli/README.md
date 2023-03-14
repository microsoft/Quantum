# Resource estimation with Q# and VS Code

👋 Welcome to Azure Quantum Resources Estimation. In this Q# project we will
guide you how to estimate the costs of integer factorization on a fault-tolerant
quantum computer.

## Azure login and workspace setup

The following steps only need to be done when starting to work with this
project.

Log into Azure using the following command (this will open a browser window):

```sh
az login
```

Set your subscription ID (you can find the subscription ID under _Essentials_ on
the _Overview_ page of your Azure Quantum Workspace):

```sh
az account set -s <subscription-id>
```

Set your resource group, workspace name, and location (you also find these under
_Essentials_ on the _Overview_ page of your Azure Quantum Workspace; the name
can be found on the top left of the browser window):

```sh
az quantum workspace set -g <resource-group> -w <workspace-name> -l <location> -o table
```

## Submit a job to Azure Quantum and read out the result

Submit a job using the following command

```sh
az quantum job submit --target-id microsoft.estimator -o json --query id
```

The output will the job ID.  Copy the ID and request the output of the job with:

```sh
az quantum job output -j <job-id> -o table
```

Let's next change the target parameters to our job. We have prepared some sample
configuration in the file `jobParams.json`. You can pass them to the
`--job-params` argument like this:

```sh
az quantum job submit --target-id microsoft.estimator -o json --query id --job-params "@jobParams.json"
```

Again you can inspect the table with

```sh
az quantum job output -j <job-id> -o table
```

You can also get all the result data in JSON format; this makes it easier to
post-process. Just change the output format from `table` to `json`:

```sh
az quantum job output -j <job-id> -o json
```

Or pipe it directly into a file:

```sh
az quantum job output -j <job-id> -o json > results.json
```

### ℹ️ Customize job target parameters

Please refer to the [Azure Quantum documentation](https://learn.microsoft.com/en-us/azure/quantum/overview-resources-estimator?tabs=tabid-qsharp-vscode) for more information on job target parameters.

## Evaluating the resources for multiple target parameters

It is possible to evaluate the resources for multiple target parameters in a
single job using batching.  We have prepared a sample job parameter file, called `jobParamsBatching.json` with 6 default qubit parameters.  You can submit the job in the same fashion:

```sh
az quantum job submit --target-id microsoft.estimator -o json --query id --job-params "@jobParamsBatching.json"
```

When you query the table for the result, you retrieve values for all items in an
overview table:

```sh
az quantum job output -j <job-id> -o table
```

You can also get the result data in a JSON format; for a batching job this will be a JSON array of results for each item:

```sh
az quantum job output -j <job-id> -o json
```

You can use the `--item` option to access an individual item, indexed by 0,
e.g., the third item:

```sh
az quantum job output -j <job-id> -o table --item 2
```

Alternatively, you can also retrieve the JSON output for an individual item of a
batching job:

```sh
az quantum job output -j <job-id> -o json --item 2
```

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

## Manifest

- [Program.qs](./Program.qs): All Q# code with `@EntryPoint` operation
- [integer-factorization.csproj](./integer-factorization.csproj): Q# project file
- [jobParams.json](./jobParams.json): Custom job parameters for resource estimation job
- [jobParamsBatching.json](./jobParamsBatching.json): Custom job parameters with multiple items for resource estimation job
