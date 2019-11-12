# Twitter Analysis on Google Cloud Platform

Proof of Concept for ingestion of twitter streams into Google BigQuery via Google Dataflow

Project layout:

* `beam-jobs/` - Python Beam jobs for loading tweests into BigQuery and for generating a list of trending topics.
* `ingest-twitter/` - scripts to ingest Tweet streams
* `sample-data/` - some already collected tweets
* `terraform/` - Infrastructure setup

## Getting started

1. Setup infra per `terraform/` folder.
2. Get twitter stream data with scripts in `ingest-twitter/` folder or use supplied sample data.
3. Copy twitter data to created Google Cloud Storage bucket.
4. Install python dependencies `pip install -r requirements.txt`
5. In `beam-jobs/`` adjust parameters in `run-import-on-gcp.sh` and run.
