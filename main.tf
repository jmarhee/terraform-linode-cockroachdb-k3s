provider "linode" {
  token = var.linode_token
}

provider "random" {
}

provider "cockroach" {
  apikey = var.cockroachdb_token
}
