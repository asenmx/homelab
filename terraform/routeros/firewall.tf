resource "routeros_ip_firewall_filter" "input_dns_udp" {
  chain             = "input"
  action            = "accept"
  protocol          = "udp"
  dst_port          = 53
  in_interface_list = "LAN"
  comment           = "Allow DNS (UDP)"
  place_before      = routeros_ip_firewall_filter.input_drop_not_lan.id
}

resource "routeros_ip_firewall_filter" "input_dns_tcp" {
  chain        = "input"
  action       = "accept"
  protocol     = "tcp"
  dst_port     = 53
  comment      = "Allow DNS (TCP)"
  place_before = routeros_ip_firewall_filter.input_drop_not_lan.id
}
resource "routeros_ip_firewall_filter" "input_established" {
  chain            = "input"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "accept established,related,untracked"
}

resource "routeros_ip_firewall_filter" "input_invalid" {
  chain            = "input"
  action           = "drop"
  connection_state = "invalid"
  comment          = "drop invalid"
}

resource "routeros_ip_firewall_filter" "input_icmp" {
  chain    = "input"
  action   = "accept"
  protocol = "icmp"
  comment  = "accept ICMP"
}

resource "routeros_ip_firewall_filter" "input_drop_not_lan" {
  chain             = "input"
  action            = "drop"
  in_interface_list = "!LAN"
  comment           = "drop all not coming from LAN"
}

resource "routeros_ip_firewall_filter" "forward_established" {
  chain            = "forward"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "accept established,related,untracked"
}

resource "routeros_ip_firewall_filter" "forward_invalid" {
  chain            = "forward"
  action           = "drop"
  connection_state = "invalid"
  comment          = "drop invalid"
}

resource "routeros_ip_firewall_filter" "forward_ipsec_in" {
  chain        = "forward"
  action       = "accept"
  ipsec_policy = "in,ipsec"
  comment      = "accept in ipsec policy"
}

resource "routeros_ip_firewall_filter" "forward_ipsec_out" {
  chain        = "forward"
  action       = "accept"
  ipsec_policy = "out,ipsec"
  comment      = "accept out ipsec policy"
}

resource "routeros_ip_firewall_filter" "forward_drop_wan_not_dstnat" {
  chain                = "forward"
  action               = "drop"
  in_interface_list    = "WAN"
  connection_nat_state = "!dstnat"
  comment              = "drop all from WAN not DSTNATed"
}
resource "routeros_ip_firewall_filter" "main_to_office" {
  action       = "accept"
  chain        = "forward"
  src_address  = var.mainpc
  dst_address  = var.networks.kubernetes.cidr
  comment      = "[terraform] accept main to office"
  place_before = routeros_ip_firewall_filter.forward_drop_wan_not_dstnat.id
}

resource "routeros_ip_firewall_filter" "office_to_main" {
  action       = "accept"
  chain        = "forward"
  src_address  = var.networks.kubernetes.cidr
  dst_address  = var.mainpc
  comment      = "[terraform] accept office to main"
  place_before = routeros_ip_firewall_filter.forward_drop_wan_not_dstnat.id
}
resource "routeros_ip_firewall_filter" "access_api" {
  action       = "accept"
  chain        = "input"
  src_address  = var.mainpc
  dst_address  = var.office_gateway
  dst_port     = 443
  protocol     = "tcp"
  comment      = "[terraform] accept mikrotik api requests from main pc"
  place_before = routeros_ip_firewall_filter.input_drop_not_lan.id
}

resource "routeros_ip_firewall_filter" "access_winbox" {
  action       = "accept"
  chain        = "input"
  src_address  = var.mainpc
  dst_address  = var.office_gateway
  dst_port     = 8291
  protocol     = "tcp"
  comment      = "[terraform] accept mikrotik winbox requests from main pc"
  place_before = routeros_ip_firewall_filter.input_drop_not_lan.id
}

resource "routeros_ip_firewall_nat" "rule" {
  action      = "masquerade"
  chain       = "srcnat"
  src_address = var.mainpc
  dst_address = var.networks.kubernetes.cidr
  comment     = "[terraform] masq main pc to office"
}
resource "routeros_firewall_filter" "allow_bgp" {
  for_each = toset(var.k8s_nodes)

  chain        = "input"
  protocol     = "tcp"
  dst_port     = 179
  src_address  = each.value
  action       = "accept"
  comment      = "[terraform] allow BGP from ${each.value}"
  place_before = routeros_ip_firewall_filter.input_drop_not_lan.id
}

