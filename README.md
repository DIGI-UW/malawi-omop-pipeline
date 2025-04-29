# OMOP Pipeline

This repository contains a SQLMesh project for transforming subsets of data from the OHDL / OpenMRS record format into the OHDSI OMOP CDM v5.4, the latest at the time of this projects initiation.

This project is organized following SQLMesh's conventions with a small wrapper using the [uv](https://github.com/astral-sh/uv) tool to manage SQLMesh and other Python dependencies. Effort is made to make this as easy to setup as possible.

## Installation Requirements

In order to install and use the project you will need to have [Python 3.13](https://www.python.org/downloads/) or later installed as well as [`uv`](https://docs.astral.sh/uv/getting-started/installation/). For the intial setup, run:

```bash
uv sync
```

To ensure the environment is setup correctly. From there, you should be able to run the [SQLMesh CLI](https://sqlmesh.readthedocs.io/en/stable/quickstart/cli/) as normal or via `uv run`, e.g.,

```bash
uv run sqlmesh plan
# or
sqlmesh plan
```

## Working with sqlmesh

In order to run the pipelines, you can simply use the command:

```bash
sqlmesh plan
```

Or, to only run the pipeline for a specific model, use:

```bash
sqlmesh plan ghii_omop.visit_occurrence
```

Note that currently, all models are implemented using SQLMesh's [FULL](https://sqlmesh.readthedocs.io/en/stable/concepts/models/model_kinds/#full) kind, which means that each run will process all data for the domain in OHDL.

### How SQLMesh Works

For a full overview of SQLMesh, please review [the relevant documentation](https://sqlmesh.readthedocs.io/en/stable/concepts/overview/). Basically, SQLMesh allows us to describe how to transform data from the format it's in into different tables using "models" which describe these translations. For the purposes of this project, our models are all [SQL models](https://sqlmesh.readthedocs.io/en/stable/concepts/models/sql_models/) which use a superset of SQL syntax to define them. In essence, a SQL model is a SQL `SELECT` statement that describes the resulting table that should be created. Each model describes the process for creating a single table. Models can depend on data created by other models, in which case the dependent models will be created after the models they depend on.

In addition to models, SQLMesh includes two concepts that are useful for ensuring the correctness of the pipeline and the correctness of the data. These tools are [tests](https://sqlmesh.readthedocs.io/en/stable/concepts/tests/) and [audits](https://sqlmesh.readthedocs.io/en/stable/concepts/audits/). Tests are aimed at verifying that the output of each model matches expectations. Tests are defined at the model level using a single YAML file. Each test can feed multiple rows of data through the transformation and ensure that the results are what are expected. Audits provide a different level of control. These are basically data quality checks that are run against the production data once its been transformed. Audits are useful for ensuring business rules are followed and that there are no "unexpected" outputs.

## Mapping OHDL to OMOP

The goal of this project is to semantically map relevant subsets of the data stored in OHDL into the OMOP CDM according to [rules described for the CDM](https://ohdsi.github.io/CommonDataModel/cdm54.html) as well as any relevant detailed notes stored by the OHDSI community in [the THEMIS repository](https://ohdsi.github.io/Themis/index.html), which is the repository for ratified OMOP conventions.

However, since the goal of this project is to produce output in the OMOP format that is useful for GHII, we occassionally deviate from either OMOP CDM rules or THEMIS conventions where adopting those rules or conventions would make the task of analyzing data derived from OHDL harder. For example, most concept-based data is not converted using OMOPs standard vocabularies, but instead using the terminology local to OHDL, since this effectively forms a data dictionary of the OHDL data. These deviations as well as assumptions and conventions adopted are documented in the files found in the `documentation/` folder.
