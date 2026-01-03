resource "routeros_routing_bgp_instance" "cilium" {
  name          = "cilium"
  as            = "65001"
  router_id     = var.office_gateway
  routing_table = "main"
}

resource "routeros_routing_bgp_connection" "cilium_peers" {
  for_each = toset(var.k8s_nodes)

  name     = "neighbor-${each.key}"
  instance = routeros_routing_bgp_instance.cilium.name

  as           = routeros_routing_bgp_instance.cilium.as
  add_path_out = "none"

  remote {
    address = each.value
    as      = "65000"
  }

  local {
    role = "ebgp"
  }
}
