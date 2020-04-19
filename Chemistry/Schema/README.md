# Schema #

This folder contains the definition of the Broombridge schema and a validator to check that a given YAML file is a valid description of a Broombridge integral data set.

## Running the Validator Tool ##

The validator tool is a Python script `validator.py` that checks given YAML documents against a JSON schema such as the default `broombridge-0.2.schema.json` file in used to define quantum chemistry problems.

To run the tool, ensure that you have either `ruamel_yaml` or [PyYAML](https://pyyaml.org/wiki/PyYAMLDocumentation) installed and that you have the [`jsonschema`](https://python-jsonschema.readthedocs.io/en/latest/) package installed.
At your favorite command line, run `validator.py` with an instance of the schema to be tested.
For example:

```bash
python validator.py ..\IntegralData\Broombridge_v0.2\broombridg
e_v0.2.yaml
```

If the instance is not a valid instance, then an exception will be raised that details how the instance failed validation.
