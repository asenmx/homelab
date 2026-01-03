resource "routeros_interface_ethernet" "interfaces" {
  for_each = var.interfaces

  factory_name = each.key
  name         = each.key
  comment      = "${var.terraform_tag} ${each.value.role} (${each.value.speed})"
}

