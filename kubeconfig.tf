data "external" "k3s_config" {
  depends_on = [linode_instance.control-plane-init, linode_instance.control-plane-replica]
  program    = ["/bin/bash", "${path.module}/scripts/retrieve_kubeconfig.sh", "${linode_instance.control-plane-init.ip_address}", "${pathexpand(format("%s", local.ssh_key_name))}", "${linode_nodebalancer.kubernetes_lb.ipv4}"]
}

resource "local_file" "cluster_k3s_config" {
  content         = textdecodebase64(data.external.k3s_config.result.kubeconfig, "UTF-8")
  filename        = pathexpand(format("%s-config", var.cluster_name))
  file_permission = "0600"
}
