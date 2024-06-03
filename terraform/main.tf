provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "azurekeyvault" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = ["10.224.0.0/12"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.224.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    pod_cidr          = "10.244.0.0/16"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.postgres_server_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  administrator_login          = data.azurekeyvault_secret.postgres_admin_user.value
  administrator_login_password = data.azurekeyvault_secret.postgres_admin_password.value
  sku_name                     = "Standard_B1ms"

  storage {
    storage_size_gb = 32
  }

  version = "13"

  delegated_subnet_id = azurerm_subnet.aks_subnet.id

  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_database" "maatdb" {
  name                = var.postgres_db_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

data "azurekeyvault_secret" "postgres_admin_password" {
  name         = "PostgresAdminPassword"
  key_vault_id = azurerm_key_vault.example.id
}

data "azurekeyvault_secret" "postgres_admin_user" {
  name         = "PostgresAdminUser"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault" "example" {
  name                = "${var.prefix}-kv"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "get",
      "list",
    ]
  }
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}
