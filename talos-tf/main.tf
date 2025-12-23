data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version 
  filters = {
    names = [
      "siderolabs/iscsi-tools",
      "siderolabs/util-linux-tools",
    ]
  }
}
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}
data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

locals {
  common_machine_config = {
    machine = {
      features = {
        kubePrism = {
          enabled = true
          port    = 7445
        }
        hostDNS = {
          enabled              = true
          forwardKubeDNSToHost = true
        }
      }
    }
    cluster = {
      discovery = {
        enabled = false
      }
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  }
}


data "talos_machine_configuration" "this" {
  for_each         = var.nodes
  cluster_name     = var.cluster_name
  machine_type     = each.value.type
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    yamlencode(local.common_machine_config),
    yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              interface = each.value.interface
              addresses = ["${each.value.address}/16"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                  metric  = 1024
                }
              ]
              mtu = 1500
            }
          ]
          nameservers = [
            var.dns
          ]
        }
      }
    })
  ]
}


resource "talos_machine_configuration_apply" "this" {
  for_each                    = var.nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  node                        = each.value.address
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration

  config_patches = [
    yamlencode({
      machine = {
        network = {
          interfaces = []
        }
        install = {
          disk  = "/dev/sda"
          image = data.talos_image_factory_urls.this.urls.disk_image
        }
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      auto       = "off"
      hostname   = each.key
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = var.nodes["cp1"].address
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.nodes["cp1"].address
}

data "talos_client_configuration" "this" {
  cluster_name         = "homelab"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [var.nodes["cp1"].address]
}

resource "local_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}

resource "local_sensitive_file" "talosconfig" {
  content    = data.talos_client_configuration.this.talos_config
  filename   = "${path.module}/talosconfig"
}

