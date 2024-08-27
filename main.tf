terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = "practical-vnet"
  location = var.location
  resource_group_name = var.resource_group
  address_space = var.vnet_address_space
}

resource "azurerm_subnet" "subnet" {
  count = length(var.subnet)

  name = var.subnet[count.index].name
  resource_group_name = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.subnet[count.index].address_prefixes
}

resource "azurerm_container_registry" "acr" {
  name = var.acr_name
  resource_group_name = var.resource_group
  location = var.location
  sku = "Basic"
  admin_enabled = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = var.aks_cluster_name
  resource_group_name = var.resource_group
  location = var.location
  dns_prefix = var.aks_cluster_name
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name = "syspool"
    vm_size = "Standard_B2s"
    auto_scaling_enabled = true
    node_count = 1
    min_count = 1
    max_count = 5
    max_pods = 30
    os_disk_type = "Managed"
    os_disk_size_gb = 32
    os_sku = "AzureLinux"
  }
}

resource "azurerm_role_assignment" "aksrole" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}