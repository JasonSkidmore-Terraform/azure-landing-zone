output "ids" {
  value = {
    id           = azurerm_linux_virtual_machine_scale_set.vmss.id
    unique_id    = azurerm_linux_virtual_machine_scale_set.vmss.unique_id
    principal_id = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
  }
}