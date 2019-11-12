data "google_project" "project" {}

resource "google_project_iam_member" "permissions" {
  role = "roles/iam.serviceAccountShortTermTokenMinter"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset" "twitter" {
  dataset_id                  = "twitter${var.suffix}"
  friendly_name               = "Tweet Analysis Dataset"
  description                 = "Dataset for Analysis of trending keywords in Tweets"
  location                    = "EU"
  default_table_expiration_ms = 1209600000 # let's clean up everything after two weeks
  delete_contents_on_destroy  = true
  labels = {
    env = "poc"
  }

  depends_on = [google_project_iam_member.permissions]
}

resource "google_bigquery_table" "tweets" {
  dataset_id = "${google_bigquery_dataset.twitter.dataset_id}"
  table_id   = "tweets"

  time_partitioning {
    type = "DAY"
    expiration_ms = 259200000    # expire after 3 days
  }

  labels = {
    env = "poc"
  }

  schema = <<EOF
[
    {
        "name": "id",
        "type": "STRING",
        "mode": "REQUIRED"
    },
    {
        "name": "author_id",
        "type": "STRING",
        "mode": "REQUIRED"
    },
    {
        "name": "created_at",
        "type": "TIMESTAMP",
        "mode": "REQUIRED"
    },
    {
        "name": "place_id",
        "type": "STRING"
    },
    {
        "name": "lang",
        "type": "STRING"
    },
    {
        "name": "text",
        "type": "STRING"
    },
    {
        "name": "keywords",
        "type": "STRING",
        "mode": "REPEATED"
    },
    {
        "name": "place_name",
        "type": "STRING"
    },
    {
        "name": "place_country",
        "type": "STRING"
    },
    {
        "name": "hashtags",
        "type": "STRING",
        "mode": "REPEATED"
    }
]
EOF
}

resource "google_bigquery_table" "trends" {
  dataset_id = "${google_bigquery_dataset.twitter.dataset_id}"
  table_id   = "trends"

  time_partitioning {
    type = "DAY"
#    expiration_ms = 259200000    # expire after 3 days
  }

  labels = {
    env = "poc"
  }

  schema = <<EOF
[
    {
        "name": "time",
        "type": "TIMESTAMP",
        "mode": "REQUIRED"
    },
    {
        "name": "keyword",
        "type": "STRING",
        "mode": "REQUIRED"
    },
    {
        "name": "occurrences",
        "type": "INTEGER",
        "mode": "REQUIRED"
    }
]
EOF
}

resource "google_bigquery_data_transfer_config" "default" {
  display_name                = "tweet trends${var.suffix}"
  location                    = "EU"
  data_refresh_window_days    = 0
  data_source_id              = "scheduled_query"
  schedule                    = "every 1 hours"
  destination_dataset_id      = "${google_bigquery_dataset.twitter.dataset_id}"
  params                      = {
    destination_table_name_template = "trends"
    write_disposition = "WRITE_APPEND"
    query = <<EOF
SELECT
    CURRENT_TIMESTAMP() AS time,
    keyword, COUNT(*) AS occurrences
FROM
    ${google_bigquery_table.tweets.dataset_id}.${google_bigquery_table.tweets.table_id},
    UNNEST(keywords) AS keyword
GROUP BY keyword
ORDER BY occurrences DESC
LIMIT 10;
EOF
  }

  depends_on = [google_project_iam_member.permissions]
}

resource "google_storage_bucket" "twitter" {
  name   = "global-datacenter-twitter${var.suffix}"
  location = "EU"
}
