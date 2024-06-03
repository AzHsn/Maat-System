variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "maat-system"
}

variable "location" {
  description = "The Azure location to deploy the resources"
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "maat"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "postgres_server_name" {
  description = "The name of the PostgreSQL server"
  type        = string
  default     = "maatdb-server"
}

variable "postgres_db_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "maat"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "aks-vnet-95045371"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "aks-subnet"
}
