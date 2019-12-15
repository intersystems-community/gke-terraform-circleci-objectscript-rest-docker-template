terraform {
  required_version = "~> 0.12"
  backend "gcs" {
    bucket      = "<BUCKET_NAME>"
    prefix      = "terraform/state"
    credentials = "account.json"
  }
}

provider "google" {
  credentials = file("account.json")
  project     = "<PROJECT_ID>"
  region      = "<REGION>"
}

resource "google_container_cluster" "gke-cluster" {
  name                     = "<CLUSTER_NAME>"
  location                 = "<LOCATION>"
  remove_default_node_pool = true
  # In regional cluster (location is region, not zone) this is a number of nodes per zone
  initial_node_count = 1
}

resource "google_container_node_pool" "preemptible_node_pool" {
  name     = "<NODES_POOL_NAME>"
  location = "<LOCATION>"
  cluster  = google_container_cluster.gke-cluster.name
  # In regional cluster (location is region, not zone) this is a number of nodes per zone
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }
}

