# Process for contributing notebook samples to the Azure Quantum portal experience

This document focuses on the process for creating samples that will eventually appear in the hosted notebooks sample gallery in the portal. If you are creating a sample for other purposes or means of consumption, then this document might not apply to your scenario.

There are three steps involved in contributing a new sample.

1. Write the notebook sample
1. Test it in the portal
1. Merge it into `main`

Once it is merged, a service engineer must be notified to add it to the sample gallery. (This engineer can be contacted by the PR approver.) Once done, the sample will be publicly available in the next deployment, usually within a week.

## Writing the sample

There are a few principles to keep in mind when writing samples that are going to be presented in the portal's sample gallery.

1. The command to log in to Azure Quantum should be in its own cell (if applicable to the notebook).
1. There should be no empty cells in the notebook.
1. To run in the portal notebook experience, the notebook must be entirely self-contained; it cannot reference other files on disk.
1. Try to keep samples short and runnable within 5 minutes. This gives users the best experience rather than starting a sample that may take hours to run (avoid qpu targets, except in suggestions for things to try next, since qpu targets can queue for a long time).
1. Try to keep to using provider targets that are free, so that users are not unexpectedly charged or lose credits if choosing to run all cells. If using cells that consume money/credits, consider commenting out the cell or requiring some kind of user input to run against the non-free target.
1. Put yourself in the user's shoes and try to address any points of confusion or longer wait times (such as if cell runs for 30 seconds, try to warn the user in the markdown cell before it). If cell will submit several jobs, try to note how many jobs will be submitted and add ("Submitting x of n jobs... print logs, so that they can see their current progress).

### Structuring files

There are also requirements file structuring and metadata that enable inclusion in aka.ms/try-qsharp and docs.microsoft.com/samples.

```yaml
binder-index.md # Should link to subject area and each way of using each sample
samples/
  subject-area/
  README.md # Should describe subject area and link to constituent samples
  sample-name/
    README.md # Should have YAML header for docs.ms/samples and manifest section
    sample-name.ipynb
    sample-name.csproj # Not yet supported in portal context.
```

Check our existing samples for reference. Also note that `binder-index.md` is at the repo root, not the sample folder.

## Testing the sample

Once the sample is written and working locally, you can test it out in the hosted environment in the Azure Portal. In order to make it appear in the sample gallery, you must access the Portal using a special link:

`https://portal.azure.com/?microsoft_azure_quantum_include_notebook_sample_with_url={URL of the raw sample file}`.
Your browser should automatically URL-encode the URL you paste, so don't worry about special characters.

Make sure that the sample is rendering correctly, all cells run successfully, and that the login details are auto-populated with the correct information for the workspace.

## Creating the PRs

Create a PR against `main` with the notebook sample. In this PR, you must include a few details:

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

When the PR is raised, an Azure DevOps pipeline will be kicked off. It will take a while and can be a little flakey. If need be, it can be manually bypassed if the tests are failing due to reasons unrelated to your change. Note that if you are adding a new sample, it will not be run in this execution, however it will be run before the change is deployed to the portal. Thus, you do not need to make any extra effort to ensure that the notebook sample is covered by the E2E tests.

> Note that the aforementioned pipeline is not publicly visible. External contributors will need to obtain approval by a member of the Azure Quantum team to invoke it.
