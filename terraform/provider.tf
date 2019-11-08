#
# Our credentials.
#
provider "google" {
  version = "~> 2.19"
  credentials = "${file("account.json")}"
  project = "global-datacenter"
  region = "eu-west1"
}
