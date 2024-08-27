variable "resource_group" {
  description = "Resource group name"
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet" {
  type = list(object({
    name = string
    address_prefixes = list(string)
  }))
}

variable "acr_name" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}