# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

try:
    import ruamel_yaml as yaml
except ImportError:
    try:
        import ruamel.yaml as yaml
    except ImportError:
        import yaml

import json
import jsonschema
import click
from sys import exit, stderr
from glob import glob

@click.command()
@click.argument("instance", type=str)
@click.argument("schema", type=str, default="broombridge-0.2.schema.json")
def validate(instance, schema):
    """
    Given a YAML-serialized object, determines if
    that object is a valid instance of a given schema.
    """
    failed = []
    schema_data = {}
    broombridge_v0_1 = "broombridge-0.1.schema.json"
    broombridge_v0_2 = "broombridge-0.2.schema.json"
    
    # Get version number
    def get_schema_name(instance_data):
        version_number = instance_data['format']['version']
        if version_number == "0.1":
            return broombridge_v0_1
        elif version_number == "0.2":
            return broombridge_v0_2
        else:
            return schema

    for schema_path in [schema, broombridge_v0_1, broombridge_v0_2]:
        with open(schema_path, 'r') as f:
            schema_data[schema_path] = json.load(f)

    for instance_path in glob(instance, recursive=True):
        with open(instance_path, 'r') as f:
            instance_data = yaml.load(f)
        
        try:
            schema_name = get_schema_name(instance_data)
            jsonschema.validate(instance_data, schema_data[schema_name])
        except jsonschema.ValidationError as ex:
            print(f"Validation of {instance_path} failed with exception:\n{ex}")
            failed.append(instance_path)
        else:
            print(f"{instance_path} is a valid instance of {schema_name}.")

    if failed:
        stderr.write("\n\nThe following files failed validation:\n")
        stderr.write("\n".join(failed))
        stderr.write("\n\n")
        exit(-1)

if __name__ == "__main__":
    
    validate()
    
