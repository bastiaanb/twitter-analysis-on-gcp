# Terraform setup for Tweet analysis application

This will deploy:
* a BigQuery table for Tweets
* a BigQuery table for Trends
* a ScheduledQuery to calculate Trends from Tweets
* a Google Cloud Function that presents the trends as a JSON feed on an HTTP endpoint
* necessary GCS buckets, API enablement, etc.

## Prerequisites:

### Install and configure the gcloud command line tool

See https://cloud.google.com/sdk/gcloud/ for instructions for your platform.

Create a service account and key for Google Cloud Platform
```
gcloud iam service-accounts create myserviceaccount
gcloud iam service-accounts keys create account.json --iam-account=myserviceaccount@global-datacenter.iam.gserviceaccount.com
```

Enable service enablement API:
```
gcloud services enable serviceusage.googleapis.com
```

### Terraform setup

#### Download

Download terraform from: https://www.terraform.io/downloads.html

# Install plugin for GCP

```
$ make init
```

#### Configure

Account informaton is already present in the file `account.json`.
The default GCP project is `global-datacenter`, change to your project in `variables.tf`, or in the STACK specific variable files in the `stacks/` dir.

# Provision the platform

```
$ make plan
$ make apply
```

By default the Makefile will create a stack for the `dev` environment. To create another environment set make variable `STACK`. E.g.

```
$ make apply STACK=prod
```

Make sure you have a variable file `stacks/<stack-name>/tfvars` with stack specific settings. At minimum it should define a `suffix` variable, to make all resource names unique per stack.

## Testing
The JSON Feed webservice can be tried out with

```
$ make test
```

NB. Currently it just invokes the HTTP endpoint but does not verify the results.
