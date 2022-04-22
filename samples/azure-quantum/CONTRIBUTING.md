# Process for contributing notebook samples to the Azure Quantum portal experience

This document focuses on the process for creating samples that will eventually appear in the hosted notebooks sample gallery in the portal. If you are creating a sample for other purposes or means of consumption, then this document might not apply to your scenario. (If you are interested in contributing an optimization notebook sample, please see [the microsoft/qio-samples repository](https://github.com/microsoft/qio-samples)).

There are three steps involved in contributing a new sample.

1. Write the notebook sample
1. Test it in the portal
1. Merge it into `main` AND into `feature/samples-gallery`

Once it is merged, a service engineer must be notified to add it to the sample gallery. Once done, the sample will be publicly available in the next deployment, usually within a week.

## Writing the sample

There are a few principles to keep in mind when writing samples that are going to be presented in the portal's sample gallery.
1. The command to log in to Azure Quantum should be in its own cell.
1. There should be no empty cells in the notebook.
1. The notebook must be entirely self-contained; it cannot reference other files on disk.

## Testing the sample
Once the sample is written and working locally, you can test it out in the hosted environment in the Azure portal. In order to make it appear in the sample gallery, you must access the portal using a special link:

`https://portal.azure.com/?microsoft_azure_quantum_include_notebook_sample_with_url={URL of the raw sample file}`.
Your browser should automatically  URL-encode the URL you paste, so don't worry about special characters.

Make sure that the sample is rendering correctly, all cells run successfully, and the login details are auto-populated with the correct information for the workspace.

## Creating the PRs
First, create a PR against `main` with the notebook sample. Once that is merged, you are ready to merge it back into `feature/samples-gallery`. You might not be able to merge the `main` branch entirely into `feature/samples-gallery` due to some divergence they have, so just create a new branch based on `feature/samples-gallery` and check out your new files for the notebook samples from `main`. In this PR, you must include a few details:

1. The title of the sample. This should be around 20 characters at the most.
1. A brief description of the sample following these guidelines:
   - Length target of 85 characters (+/- 15 characters at the most)
   - Should not begin with “This sample” or other boilerplate wording
   - Should not mention the provider (as that is already noted on the tile)
   - Should speak in an implied 2nd-person view (“Run a job” preferred over “You can run a job”)
   - Verbiage should be specific to function and obvious if correlated to other samples in the gallery
   - Must be approved by a UX designer and PM
1. The provider that the sample targets (e.g. IonQ or Quantinuum). If the sample does not target any providers, explicitly indicate this in the PR summary.

### E2E tests
When the PR is raised, [this pipeline](https://ms-quantum.visualstudio.com/Quantum%20Program/_build?definitionId=589) will be kicked off. It will take a while and can be a little flakey. If need be, it can be manually bypassed if the tests are failing due to reasons unrelated to your change. Note that if you are adding a new sample, it will not be run in this execution, however it will be run before the change is deployed to the portal. Thus, you do not need to make any extra effort to ensure that the notebook sample is covered by the E2E tests.
