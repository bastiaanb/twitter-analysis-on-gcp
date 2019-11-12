# Twitter Analysis on Google Cloud Platform

Proof of Concept for ingestion of twitter streams into Google BigQuery via Google Dataflow

Project layout:

* `ingest-twitter/` - scripts to ingest Tweet streams
* `terraform/` - Infrastructure setup
* `beam-jobs/` - Python Beam jobs for loading tweests into BigQuery and for generating a list of trending topics.
