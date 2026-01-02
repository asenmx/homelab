variable "mainpc" {
  type        = string
  description = "Trusted management workstation IP"
}

variable "interfaces" {
  type = map(object({
    role  = string
    speed = string
    usage = string
    mtu   = optional(number)
  }))
}

variable "networks" {
  type = map(object({
    cidr      = string
    interface = string
    comment   = string
  }))
}

variable "leases" {
  type = map(object({
    ip   = string
    mac  = string
    role = string
  }))

  validation {
    condition = alltrue([
      for l in values(var.leases) :
      can(regex("^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$", l.mac))
    ])
    error_message = "Invalid MAC address detected."
  }
}
variable "dns_records" {
  description = "Additional static DNS records not derived from DHCP leases"
  type        = map(string)
  default     = {}
}

variable "dhcp_ranges" {
  type = list(string)
}

variable "office_gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "wg_private_key" {
  type      = string
  sensitive = true
}

variable "wg_peer_public_key" {
  type = string
}

variable "wg_port" {
  type    = number
  default = 5180
}

variable "terraform_tag" {
  type    = string
  default = "[terraform]"
}
variable "k8s_nodes" {
  type = list(string)
}
