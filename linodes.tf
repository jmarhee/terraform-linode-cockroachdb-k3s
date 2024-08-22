data "template_file" "control-plane-init" {
  depends_on = [cockroach_cluster.rancherdb] # linode_database_postgresql.rancherdb
  template   = file("${path.module}/templates/control-plane-init.tpl")
  vars = {
    ####
    # https://www.linode.com/community/questions/24834/postgresql-managed-database-404
    # Linode has PAUSED managed database provisioning.
    ####
    # RANCHER_DATA_SOURCE   = format("postgresql://%s:%s@%s:5432/console", linode_database_postgresql.rancherdb.root_username, linode_database_postgresql.rancherdb.root_password, linode_database_postgresql.rancherdb.host_primary)
    RANCHER_DATA_SOURCE = "postgres://${cockroach_sql_user.rancherdb.name}:${random_string.rancherdb_password.result}@${cockroach_cluster.rancherdb.regions.0.sql_dns}:26257/rancherdb?sslmode=require"
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
    LOAD_BALANCER_VIP   = linode_nodebalancer.kubernetes_lb.ipv4
  }
}

resource "linode_stackscript" "control-plane-init" {
  label       = "Initialize Rancher k3s Control Plane"
  description = "Initialization script for Rancher k3s control plane."
  script      = data.template_file.control-plane-init.rendered
  images      = ["linode/opensuse15.6"]
  is_public   = false
}

resource "linode_instance" "control-plane-init" {
  depends_on = [cockroach_cluster.rancherdb, linode_nodebalancer.kubernetes_lb] # linode_database_postgresql.rancherdb

  label           = "${var.cluster_name}-control-plane-00"
  image           = "linode/opensuse15.6"
  region          = var.cluster_region
  type            = var.control_plane_size
  authorized_keys = [local_file.cluster_public_key.content]

  interface {
    purpose = "public"
  }

  stackscript_id = linode_stackscript.control-plane-init.id

  tags       = ["${var.cluster_name}-control-plane"]
  swap_size  = 256
  private_ip = false
}

data "template_file" "control-plane-replica" {
  depends_on = [cockroach_cluster.rancherdb, linode_instance.control-plane-init] # linode_database_postgresql.rancherdb
  template   = file("${path.module}/templates/control-plane-replica.tpl")
  vars = {
    ####
    # https://www.linode.com/community/questions/24834/postgresql-managed-database-404
    # Linode has PAUSED managed database provisioning.
    ####
    # RANCHER_DATA_SOURCE   = format("postgresql://%s:%s@%s:5432/console", linode_database_postgresql.rancherdb.root_username, linode_database_postgresql.rancherdb.root_password, linode_database_postgresql.rancherdb.host_primary)
    RANCHER_DATA_SOURCE   = "postgres://${cockroach_sql_user.rancherdb.name}:${random_string.rancherdb_password.result}@${cockroach_cluster.rancherdb.regions.0.sql_dns}:26257/rancherdb?sslmode=require"
    GENERATED_K3S_TOKEN   = random_string.k3s_token.result
    LOAD_BALANCER_VIP     = linode_nodebalancer.kubernetes_lb.ipv4
    CONTROL_PLANE_INIT_IP = linode_instance.control-plane-init.ip_address
  }
}

resource "linode_stackscript" "control-plane-replica" {
  label       = "Initialize Rancher k3s Control Plane"
  description = "Initialization script for Rancher k3s control plane."
  script      = data.template_file.control-plane-replica.rendered
  images      = ["linode/opensuse15.6"]
  is_public   = false
}

resource "linode_instance" "control-plane-replica" {
  depends_on = [cockroach_cluster.rancherdb, linode_nodebalancer.kubernetes_lb] # linode_database_postgresql.rancherdb

  label           = format("${var.cluster_name}-control-plane-%02d", count.index + 1)
  image           = "linode/opensuse15.6"
  region          = var.cluster_region
  type            = var.control_plane_size
  count           = var.controller_peer_count
  authorized_keys = [local_file.cluster_public_key.content]

  interface {
    purpose = "public"
  }

  stackscript_id = linode_stackscript.control-plane-replica.id

  tags       = ["${var.cluster_name}-control-plane"]
  swap_size  = 256
  private_ip = false
}

data "template_file" "node" {
  depends_on = [cockroach_cluster.rancherdb, linode_instance.control-plane-init, linode_nodebalancer.kubernetes_lb] # linode_database_postgresql.rancherdb
  template   = file("${path.module}/templates/node.tpl")
  vars = {
    K3S_CONTROLLER_IP   = linode_nodebalancer.kubernetes_lb.ipv4
    GENERATED_K3S_TOKEN = random_string.k3s_token.result
  }
}

resource "linode_stackscript" "node" {
  label       = "Initialize Rancher k3s worker node"
  description = "Initialization script for Rancher k3s worker nodes."
  script      = data.template_file.node.rendered
  images      = ["linode/opensuse15.6"]
  is_public   = false
}

resource "linode_instance" "node" {
  depends_on = [cockroach_cluster.rancherdb, linode_nodebalancer.kubernetes_lb] # linode_database_postgresql.rancherdb

  label           = format("${var.cluster_name}-worker-%02d", count.index)
  image           = "linode/opensuse15.6"
  region          = var.cluster_region
  type            = var.node_size
  count           = var.worker_node_count
  authorized_keys = [local_file.cluster_public_key.content]

  interface {
    purpose = "public"
  }

  stackscript_id = linode_stackscript.node.id

  tags       = ["${var.cluster_name}-worker"]
  swap_size  = 256
  private_ip = false
}
