#
# Our credentials.
#
provider "google" {
  version = "~> 2.19"
  credentials = "${file("account.json")}"
  project = var.project
  region = "europe-west1"
}
