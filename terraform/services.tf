resource "google_project_service" "serviceusage-api" {
  service = "serviceusage.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "bigquery-json-api" {
  service = "bigquery-json.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "bigqueryconnection-api" {
  service = "bigqueryconnection.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "bigquerydatatransfer-api" {
  service = "bigquerydatatransfer.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "bigquerystorage-api" {
  service = "bigquerystorage.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "cloudapis-api" {
  service = "cloudapis.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "cloudfunctions-api" {
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "composer-api" {
  service = "composer.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "compute-api" {
  service = "compute.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "dataflow-api" {
  service = "dataflow.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "dns-api" {
  service = "dns.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "iam-api" {
  service = "iam.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials-api" {
  service = "iamcredentials.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "logging-api" {
  service = "logging.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "monitoring-api" {
  service = "monitoring.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "pubsub-api" {
  service = "pubsub.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "replicapool-api" {
  service = "replicapool.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "replicapoolupdater-api" {
  service = "replicapoolupdater.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "resourceviews-api" {
  service = "resourceviews.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "storage-api-api" {
  service = "storage-api.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "storage-component-api" {
  service = "storage-component.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy = false
}
