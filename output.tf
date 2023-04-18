output "acr_task_id" {
  description = "The ID of the created task"
  value = {
    for key, value in azurerm_container_registry_task.acr_task : key => value.id
  }
}

output "acr_task_name" {
  description = "The name of the created task"
  value = {
    for key, value in azurerm_container_registry_task.acr_task : key => value.name
  }
}

output "acr_task_identity" {
  description = "The identity block"
  value = {
    for key, value in azurerm_container_registry_task.acr_task : key => value.identity
  }
}
