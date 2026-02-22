# dbt_celebi

dbt project for Celebi analytics using a medallion layout:

- `bronze`: raw source‑aligned views (time_landing, taxi trip feeds, etc.)
- `silver`: conformed dimensions and topic facts (time dimensions, taxi trip facts)
- `gold`: business‑facing marts for performance, rides analysis and Looker core

---

## Project structure

The repository is organised according to the conventional dbt medallion pattern:

```
dbt_celebi/
  analyses/                  # adhoc analyses
  macros/                    # reusable SQL macros and utilities
  models/
    bronze/                  # raw staging models and source definitions
      time_landing/
        raw_yml_sources/     # source YAMLs
        stg_base_cleanup/    # simple cleanup models
    example/                 # example models shipped with the starter project
    silver/                  # conformed dimensions & fact tables
      time_dimensions/
        final/               # final dim_dates
      time_facts/
        stage_2_transform/   # intermediate staging for taxi trips
        final/               # final fact_taxi_trips
    gold/                    # marts built on silver models
      looker_core/           # Looker‑ready views (dates, taxi_stats, trips)
  seeds/                     # static seed files (if any)
  snapshots/                 # snapshot definitions
  tests/                     # custom tests

```


## Core modeling principles

* **Single source of truth** per topic in the silver layer:
  * sales/fact metrics in `fact_taxi_trips` (daily grain)
  * temporal dimensions in `dim_dates`
* Gold models are consumption‑ready aggregations built on silver facts/dimensions.
* Daily grain is used for marts unless explicitly stated otherwise.


## How to build & test locally

```bash
# install dependencies
cd dbt_celebi
dbt deps

# run everything
dbt build

dbt test
```

Use selector flags for targeted execution:

```bash
dbt build --select silver
dbt build --select gold
dbt test --select silver
dbt test --select gold

# build an individual model and its parents
dbt build --select +dim_dates

dbt build --select +fact_taxi_trips --exclude +dim_dates  # e.g. exclude if you know dim already exists
```


## Documentation

Generate an HTML site for lineage and model descriptions:

```bash
dbt docs generate
dbt docs serve
```


## Deployment readiness 🔧

This repository is designed to be containerised and built via Google Cloud Build.

* **`Dockerfile`** – a generic dbt image that pulls the official `ghcr.io/dbt-labs/dbt-core`
  base and installs additional adapter dependencies. It also runs `dbt deps`
  and sets the working directory to the project root. The image entrypoint is a
  simple `bash` shell which allows interactive debugging or CI steps such as
  `dbt build`.

* **`cloudbuild.yaml`** – instructs Cloud Build to build the Docker image and
  push it to Artifact Registry under the path
  `us-docker.pkg.dev/$PROJECT_ID/dottime-dbt-celebi/dbt-celebi:prod`.
  Substitutions are automapped so you can trigger builds with `gcloud builds submit`
  from the repo root. The resulting image is referenced by downstream CI/CD
  or Airflow jobs that need to execute dbt against your warehouse.

The combination of the Dockerfile and Cloud Build configuration makes the
project **deployment ready**: any change to models or macros can be rebuilt in
an immutable container and executed in a controlled cloud environment.


## Notes

* Project configuration lives in `dbt_project.yml`.
* Schema names for bronze/silver/gold are defined under
  `models.dbt_celebi` in the project file.
* Source YAML files for the bronze layer are located alongside the models
  (e.g. `models/bronze/time_landing/raw_yml_sources/`).


---
