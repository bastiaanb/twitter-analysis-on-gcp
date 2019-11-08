resource "google_bigquery_dataset" "twitter" {
  dataset_id                  = "twitter"
  friendly_name               = "Tweet Analysis Dataset"
  description                 = "Dataset for Analysis of trending keywords in Tweets"
  location                    = "EU"
  default_table_expiration_ms = 1209600000 # let's clean up everything after two weeks
  delete_contents_on_destroy  = true
  labels = {
    env = "poc"
  }
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
    }
]
EOF
}
