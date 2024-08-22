resource "linode_nodebalancer" "kubernetes_lb" {
  label                = "loadbalancer-1"
  region               = var.cluster_region
  client_conn_throttle = 20
  tags                 = ["${var.cluster_name}-control-plane"]

}

resource "linode_nodebalancer_config" "kubernetes_lb" {
  # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes
  nodebalancer_id = linode_nodebalancer.kubernetes_lb.id
  port            = 6443
  protocol        = "tcp"
  # ssl_key = ""
  # ssl_cert = ""
  algorithm       = "roundrobin"
  # stickiness      = "http_cookie"
}
