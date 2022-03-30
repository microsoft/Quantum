# Schema

This folder contains the definition of the Broombridge schema and a validator to check that a given YAML file is a valid description of a Broombridge integral data set.

## Running the Validator Tool

The validator tool is a Python script `validator.py` that checks given YAML documents against a JSON schema such as the default `broombridge-0.2.schema.json` file in used to define quantum chemistry problems.

To run the tool, at your favorite command line, first install the prerequisites

```bash
pip install -r requirements.txt
```

and then run `validator.py` with an instance of the schema to be tested.
For example:

```bash
python validator.py ..\IntegralData\Broombridge_v0.2\broombridg
e_v0.2.yaml
```

If the instance is not a valid instance, then an exception will be raised that details how the instance failed validation.
