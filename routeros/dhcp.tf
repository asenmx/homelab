resource "routeros_ip_pool" "office" {
  name   = "dhcp-office"
  ranges = var.dhcp_ranges
}


resource "routeros_ip_dhcp_server" "office" {
  address_pool     = routeros_ip_pool.office.name
  interface        = "bridge"
  name             = "office"
  bootp_lease_time = "forever"
  disabled         = false
}

resource "routeros_ip_dhcp_server_lease" "leases" {
  for_each = var.leases

  address     = each.value.ip
  mac_address = each.value.mac
  server      = routeros_ip_dhcp_server.office.name
  comment     = "${var.terraform_tag} ${each.key} (${each.value.role})"
}
