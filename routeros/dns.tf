resource "routeros_ip_dns_record" "records" {
  for_each = var.dns_records

  name    = each.key
  address = each.value
  type    = "A"
}
