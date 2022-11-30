# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import argparse
from azure.quantum import Workspace, Job
import json
import os
from pyqir.generator import ir_to_bitcode


# Program arguments
parser = argparse.ArgumentParser(
    prog="estimate", description="Estimate physical resources using Azure Quantum")

parser.add_argument("filename", help="Quantum program (.ll, .qir, .bc)")
parser.add_argument("-r", "--resource-id", default=os.environ.get("AZURE_QUANTUM_RESOURCE_ID"),
                    help="Resource ID of Azure Quantum workspace (must be set, unless set via environment variable AZURE_QUANTUM_RESOURCE_ID)")
parser.add_argument("-l", "--location",
                    default=os.environ.get("AZURE_QUANTUM_LOCATION"), help="Location of Azure Quantum workspace (must be set, unless set via environment AZURE_QUANTUM_LOCATION)")
parser.add_argument("-p", "--job-params", help="JSON file with job parameters")

args = parser.parse_args()

if not args.resource_id:
    parser.error("the following arguments are required: -r/--resource-id")
if not args.location:
    parser.error("the following arguments are required: -l/--location")


# Set up Azure Quantum workspace
workspace = Workspace(resource_id=args.resource_id, location=args.location)


# Create QIR bitcode (based on filename extension)
ext = os.path.splitext(args.filename)[1].lower()
if ext in ['.qir', '.ll']:
    with open(args.filename, 'r') as f:
        bitcode = ir_to_bitcode(f.read())
elif ext == '.bc':
    with open(args.filename, 'rb') as f:
        bitcode = f.read()
else:
    parser.error("unsupported file extension")


# Parse job arguments
input_params = {}
if args.job_params:
    with open(args.job_params, 'r') as f:
        input_params = json.load(f)


# Create and submit job
job = Job.from_input_data(
    workspace=workspace,
    name="Estimation job",
    target="microsoft.estimator",
    input_data=bitcode,
    provider_id="microsoft-qc",
    input_data_format="qir.v1",
    output_data_format="microsoft.resource-estimates.v1",
    input_params=input_params
)
job.wait_until_completed()


# Get results and print as JSON
result = job.get_results()
print(json.dumps(result, indent=4))
