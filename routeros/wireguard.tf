# resource "routeros_interface_wireguard" "wg0" {
#   name        = "wg0"
#   listen_port = var.wg_port
#   private_key = var.wg_private_key
# }
#
# resource "routeros_interface_wireguard_peer" "peer" {
#   interface            = routeros_interface_wireguard.wg0.name
#   public_key           = var.wg_peer_public_key
#   allowed_address      = ["10.10.0.0/24"]
#   persistent_keepalive = 25
# }
#
