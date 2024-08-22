output "kubeconfig_base64" {
  description = "Base64 encoded kubeconfig string"
  value       = data.external.k3s_config.result.kubeconfig
}

output "kubeconfig_location" {
  description = "Your Kubeconfig"
  value       = "${path.module}/${pathexpand(format("%s-config", var.cluster_name))}"
}

output "control_plane_lb_address" {
  description = "K3s Control Plane Load Balancer Address"
  value       = linode_nodebalancer.kubernetes_lb.ipv4
}

output "control_plane_nodes" {
  description = "K3s Control Plane Node IP Addresses"
  value       = concat([linode_instance.control-plane-init.ip_address], [join(", ", linode_instance.control-plane-replica.*.ip_address)])
}

output "worker_nodes" {
  description = "K3s Worker Nodes"
  value       = linode_instance.node.*.ip_address
}
