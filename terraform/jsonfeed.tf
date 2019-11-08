# zip up our source code
data "archive_file" "jsonfeed-zip" {
  type        = "zip"
  source_dir  = "${path.root}/jsonfeed/"
  output_path = "${path.root}/jsonfeed.zip"
}

# create the storage bucket
resource "google_storage_bucket" "deployment" {
  name   = "global-datacenter-deployment"
}

# place the zip-ed code in the bucket
resource "google_storage_bucket_object" "jsonfeed-zip" {
  name   = "jsonfeed.zip"
  bucket = "${google_storage_bucket.deployment.name}"
  source = "${path.root}/jsonfeed.zip"
}

resource "google_cloudfunctions_function" "jsonfeed" {
  name                  = "twitter-trends"
  description           = "Trending Twitter Topics"
  runtime               = "python37"
  region                = "europe-west1"

  available_memory_mb   = 256
  source_archive_bucket = "${google_storage_bucket.deployment.name}"
  source_archive_object = "${google_storage_bucket_object.jsonfeed-zip.name}"
  trigger_http          = true
  timeout               = 60
  entry_point           = "query_trends"
  labels = {
    env = "poc"
  }
}
