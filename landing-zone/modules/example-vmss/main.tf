locals {
  vmss_frontend_config_name = "VMSSIPConfiguration"
  vmss_network_profile_name = "TFENetworkProfile"

  # Update LB settings based on Azure LB or Azure App Gateway
  load_balancer_backend_address_pool_ids = var.lb.type == "ALB" ? [var.lb.backend_address_pool_id] : []
  # application_gateway_backend_address_pool_ids = var.lb.type == "AAG" ? [var.lb.backend_address_pool_id] : []
}

# Locate the existing custom/golden image
data "azurerm_image" "vmss" {
  name                = var.service_image
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "vmss" {
  name                    = format("%s-pip-%s", var.service_name, var.namespace)
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Dynamic"
  # domain_name_label       = "vmss-example" # Domain name for A Record using internal DNS Azure (<name>.eastus.cloudapp.azure.com)
  idle_timeout_in_minutes = 30

  tags = var.tags
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = format("%s-VMSS-%s", var.service_name, var.namespace)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku      # "Standard_F2"  "Standard_D2s_v3"
  instances           = var.instances_count
  admin_username      = var.vm_user.username

  upgrade_mode = "Manual"

  # custom_data = base64encode(var.startup_script)
  # source_image_id = data.azurerm_image.service.id

  # Managed Service Identity
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_user.username
    public_key = var.vm_user.public_key
  }

  source_image_reference {
    publisher = var.os_image.publisher
    offer     = var.os_image.offer
    sku       = var.os_image.sku
    version   = var.os_image.version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = format("%s-nic-%s", var.service_name, var.namespace)
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
      public_ip_address {
        name = azurerm_public_ip.vmss.name
        domain_name_label       = "vmss-example"
      }
      # For Public Load Balancer
      load_balancer_backend_address_pool_ids       = local.load_balancer_backend_address_pool_ids

      # For App Gateway
      # application_gateway_backend_address_pool_ids = local.application_gateway_backend_address_pool_ids 
    }
  }

  tags = var.tags
}


# # https://docs.microsoft.com/bs-latn-ba/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-health-extension
# # logs /var/lib/waagent/Microsoft.ManagedServices.ApplicationHealthLinux-1.0.0
# resource "azurerm_virtual_machine_scale_set_extension" "main" {
#   name                         = format("%s-vmss-health-ext", var.namespace)
#   virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.main.id
#   publisher                    = "Microsoft.ManagedServices"
#   type                         = "ApplicationHealthLinux"
#   auto_upgrade_minor_version   = true
#   type_handler_version         = "1.0"
#   settings = jsonencode({
#     "protocol" : "http",
#     "port" : 80,
#     "requestPath" : "/_health_check"
#   })
# }