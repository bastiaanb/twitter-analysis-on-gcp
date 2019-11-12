# zip up our source code
data "archive_file" "jsonfeed-zip" {
  type        = "zip"
  source_dir  = "${path.root}/jsonfeed/"
  output_path = "${path.root}/jsonfeed.zip"
}

# create the storage bucket
resource "google_storage_bucket" "deployment" {
  name   = "global-datacenter-deployment${var.suffix}"
  location = "EU"
}

# place the zip-ed code in the bucket
resource "google_storage_bucket_object" "jsonfeed-zip" {
  name   = "jsonfeed-${data.archive_file.jsonfeed-zip.output_base64sha256}.zip"
  bucket = "${google_storage_bucket.deployment.name}"
  source = "${data.archive_file.jsonfeed-zip.output_path}"
}

resource "google_cloudfunctions_function" "jsonfeed" {
  name                  = "twitter-trends${var.suffix}"
  description           = "Trending Twitter Topics${var.suffix}"
  runtime               = "python37"
  region                = "${var.region}"

  available_memory_mb   = 256
  source_archive_bucket = "${google_storage_bucket.deployment.name}"
  source_archive_object = "${google_storage_bucket_object.jsonfeed-zip.name}"
  trigger_http          = true
  timeout               = 60
  entry_point           = "query_trends"
  environment_variables = {
    TRENDS_TABLE = "${google_bigquery_table.trends.dataset_id}.${google_bigquery_table.trends.table_id}"
  }

  labels = {
    env = "poc"
  }
}

output "jsonfeed_url" {
  value = "${google_cloudfunctions_function.jsonfeed.https_trigger_url}"
}
