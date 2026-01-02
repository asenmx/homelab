resource "routeros_ip_address" "address" {
  for_each = var.networks

  address   = each.value.cidr
  interface = each.value.interface
  network   = cidrhost(each.value.cidr, 0)
  comment   = "${var.terraform_tag} ${each.value.comment}"
}

