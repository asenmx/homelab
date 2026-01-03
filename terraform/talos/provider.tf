terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.0-beta.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}
locals {
  talos_kubeconfig = yamldecode(talos_cluster_kubeconfig.this.kubeconfig_raw)
}

provider "kubernetes" {
  host                   = local.talos_kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.talos_kubeconfig.clusters[0].cluster.certificate-authority-data)
  client_certificate     = base64decode(local.talos_kubeconfig.users[0].user.client-certificate-data)
  client_key             = base64decode(local.talos_kubeconfig.users[0].user.client-key-data)
}

provider "helm" {
  kubernetes {
    host                   = local.talos_kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.talos_kubeconfig.clusters[0].cluster.certificate-authority-data)
    client_certificate     = base64decode(local.talos_kubeconfig.users[0].user.client-certificate-data)
    client_key             = base64decode(local.talos_kubeconfig.users[0].user.client-key-data)
  }
}
