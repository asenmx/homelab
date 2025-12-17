data "routeros_ip_firewall" "fw" {
  rules {
    filter = {
      chain             = "forward"
      comment           = "defconf: drop all from WAN not DSTNATed"
      in_interface_list = "WAN"
    }
  }
}

resource "routeros_ip_firewall_filter" "main_to_office" {
  action       = "accept"
  chain        = "forward"
  src_address  = var.mainpc
  dst_address  = var.networks.kubernetes.cidr
  comment      = "[terraform] accept main to office"
  place_before = data.routeros_ip_firewall.fw.rules[0].id
}
resource "routeros_ip_firewall_filter" "office_to_main" {
  action       = "accept"
  chain        = "forward"
  src_address  = var.networks.kubernetes.cidr
  dst_address  = var.mainpc
  comment      = "[terraform] accept office to main"
  place_before = data.routeros_ip_firewall.fw.rules[0].id
}
resource "routeros_ip_firewall_filter" "access_api" {
  action       = "accept"
  chain        = "input"
  src_address  = var.mainpc
  dst_address  = var.office_gateway
  dst_port     = 443
  protocol     = "tcp"
  comment      = "[terraform] accept mikrotik api requests from main pc"
  place_before = 5
}
resource "routeros_ip_firewall_filter" "access_winbox" {
  action       = "accept"
  chain        = "input"
  src_address  = var.mainpc
  dst_address  = var.office_gateway
  dst_port     = 8291
  protocol     = "tcp"
  comment      = "[terraform] accept mikrotik winbox requests from main pc"
  place_before = 5
}

resource "routeros_ip_firewall_nat" "rule" {
  action      = "masquerade"
  chain       = "srcnat"
  src_address = var.mainpc
  dst_address = var.networks.kubernetes.cidr
  comment     = "[terraform] masq main pc to office"
}
