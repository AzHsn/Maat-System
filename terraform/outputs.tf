output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "postgres_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}
