variable "talos_version" {
  description = "Talos OS version"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Talos cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Kubernetes API endpoint (VIP)"
  type        = string
}

variable "nodes" {
  description = "Cluster nodes definition"
  type = map(object({
    interface = string
    address   = string
    type      = string # controlplane | worker
  }))
}

variable "gateway" {
  description = "Default gateway"
  type        = string
}

variable "dns" {
  description = "DNS server IP"
  type        = string
}

