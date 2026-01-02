terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.98.0"
    }
  }
}

provider "routeros" {
  hosturl  = "https://router.local" # env ROS_HOSTURL or MIKROTIK_HOST
  insecure = true                   # env ROS_INSECURE or MIKROTIK_INSECURE
}
