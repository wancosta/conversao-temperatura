terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.11.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_k8s" {
  name     = "${var.resource_group_name}-${terraform.workspace}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s_cluster" {
  name                = "${var.cluster_name}-${terraform.workspace}"
  location            = azurerm_resource_group.resource_k8s.location
  resource_group_name = azurerm_resource_group.resource_k8s.name
  dns_prefix          = "labs-${terraform.workspace}"
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }


  default_node_pool {
    name       = "default"
    node_count = var.default_node_pool_count
    vm_size    = var.default_node_pool_size
    zones      = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "local_file" "kube_config" {
  content  = azurerm_kubernetes_cluster.k8s_cluster.kube_config_raw
  filename = "kube_config-${terraform.workspace}.yaml"
}

variable "resource_group_name" {
  default = "live-rg"
}

variable "location" {
  default = "East US"
}

variable "cluster_name" {
  default = "live-aks"
}

variable "default_node_pool_count" {
  default = 6
}

variable "default_node_pool_size" {
  default = "Standard_D2_v2"
}
