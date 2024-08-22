variable "linode_token" {
  description = "Your Linode API Token"
}

####
# https://www.linode.com/community/questions/24834/postgresql-managed-database-404
# Linode has PAUSED managed database provisioning.
# This will be used for free tier CockroachDB.
####

variable "cockroachdb_token" {
  description = "Your CockroachDB API token"
}

variable "cockroachdb_organization_id" {
  description = "Your CockroachDB Organization ID"
}

variable "cockroachdb_region" {
  description = "Region for CockroachDB"
  default     = "us-east-1" #default for free serverless tier
}

variable "serverless_spend_limit" {
  type     = number
  nullable = false
  default  = 0
}

####
# End of Cockroach DB Config
# Can be removed when Linode reopens managed database provisioning
####

variable "cluster_name" {
  description = "Cluster name"
  default     = "rancher-k3s"
}

variable "cluster_domain" {
  description = "Root Domain for Cluster"
}

variable "cluster_subdomain" {
  description = "DNS subdomain for cluster"
  default     = "k3s"
}

variable "cluster_region" {
  description = "Region for Cluster"
  default     = "us-east"
}

####
# https://www.linode.com/community/questions/24834/postgresql-managed-database-404
# Linode has PAUSED managed database provisioning.
####

# variable "database_region" {
#   description = "Region for psql Cluster"
#   default     = "us-east"
# }


variable "control_plane_size" {
  description = "Control Plane Node Size"
  default     = "g6-standard-1"
}

variable "node_size" {
  description = "Worker Node Size"
  default     = "g6-standard-1"
}

####
# https://www.linode.com/community/questions/24834/postgresql-managed-database-404
# Linode has PAUSED managed database provisioning.
####

# variable "database_size" {
#   description = "DB Node Size"
#   default     = "g6-nanode-1"
# }

variable "database_node_count" {
  description = "Number of Database nodes in psql cluster"
  default     = 3
}

variable "controller_peer_count" {
  description = "Number of additional Control Plane nodes"
  default     = 2
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  default     = 3
}
