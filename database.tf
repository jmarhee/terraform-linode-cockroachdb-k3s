resource "random_string" "rancherdb" {
  length  = 6
  special = false
  numeric = false
  upper   = false
  lower   = true
}

# resource "linode_database_postgresql" "rancherdb" {
#   label     = random_string.rancherdb.result
#   engine_id = "postgresql/15"
#   region    = var.database_region
#   type      = var.database_size


#   allow_list              = ["0.0.0.0/0"]
#   cluster_size            = var.database_node_count
#   encrypted               = true
#   replication_type        = "semi_synch"
#   replication_commit_type = "remote_write"
#   ssl_connection          = false

#   updates {
#     day_of_week   = "saturday"
#     duration      = 1
#     frequency     = "monthly"
#     hour_of_day   = 22
#     week_of_month = 2
#   }
# }

####
# https://www.linode.com/community/questions/24834/postgresql-managed-database-404
# Linode has PAUSED managed database provisioning.
####

# Remember that even variables marked sensitive will show up
# in the Terraform state file. Always follow best practices
# when managing sensitive info.
# https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#sensitive-values-in-state
resource "random_string" "rancherdb_password" {
  length  = 22
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "cockroach_cluster" "rancherdb" {
  name           = random_string.rancherdb.result
  cloud_provider = "AWS"
  serverless = {
    spend_limit = var.serverless_spend_limit
  }
  regions = [{ name = var.cockroachdb_region }]
}

resource "cockroach_sql_user" "rancherdb" {
  name       = "rancherdb"
  password   = random_string.rancherdb_password.result
  cluster_id = cockroach_cluster.rancherdb.id
}

resource "cockroach_database" "rancherdb" {
  name       = "rancherdb"
  cluster_id = cockroach_cluster.rancherdb.id
}

resource "cockroach_service_account" "rancherdb" {
  name        = "rancherdb"
  description = "A service account providing access to single cluster."
}

resource "cockroach_user_role_grant" "rancherdb_access_scoped_grant" {
  user_id = cockroach_service_account.rancherdb.id
  role = {
    role_name     = "CLUSTER_ADMIN",
    resource_type = "CLUSTER",
    resource_id   = cockroach_cluster.rancherdb.id
  }
}

resource "cockroach_api_key" "rancherdb" {
  name               = "rancherdb"
  service_account_id = cockroach_service_account.rancherdb.id
}

####
# For Demonstration Purposes (not recommended for production use); you can use control plane logic below in linodes.tf to create more robust rules for access as needed
# CockroachDB recommends configuring this as an egress address like a VPN exit node address or bastion host address,
# for example: https://registry.terraform.io/providers/cockroachdb/cockroach/latest/docs/resources/allow_list#example-usage
####
resource "cockroach_allow_list" "rancherdb" {
  name       = "rancherdb"
  cidr_ip    = "0.0.0.0"
  cidr_mask  = 0
  ui         = false
  sql        = true
  cluster_id = cockroach_cluster.rancherdb.id
}

####
# or whitelist per Linode facility: https://geoip.linode.com/ (not recommended for production use).
####

####
# https://www.linode.com/community/questions/24834/postgresql-managed-database-404
# Linode has PAUSED managed database provisioning.
####

# locals {
#   # control_planes = concat(linode_instance.control-plane-init.ip_address, join(", ", linode_instance.control-plane-replica.*.ip_address))
#   replicas = [
#     for o in linode_instance.control-plane-replica : o.ip_address
#   ]
#   control_planes = concat([linode_instance.control-plane-init.ip_address], local.replicas)
# }

# resource "cockroach_allow_list" "control_plane_rancherdb" {
#   depends_on = [linode_instance.control-plane-init, linode_instance.control-plane-replica]
#   for_each = toset(local.control_planes)
#   name       = "control-plane"
#   cidr_ip    = each.key
#   cidr_mask  = 32
#   ui         = true
#   sql        = true
#   cluster_id = cockroach_cluster.rancherdb.id
# }
