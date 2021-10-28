#--------
# Common
#--------
variable "resource_group_name" {
  default = "valkyrie-testing"
}

variable "location" {
  description = "The location to place all the resources."
  default     = "eastus"
}

variable "namespace" {
  description = "Name to assign to resources for easy organization."
}

variable "tags" {
  description = "Tags to apply to the resource group/resources."
  type        = map
  default     = {}
}

#-------
# TLS
#-------
variable "domain" {
  description = "The domain you wish to use, this will be subdomained. `example.com`"
}

variable "subdomain" {
  description = "The subdomain you wish to use `mycompany-tfe`"
}

variable "certificate_path" {
  description = "The path on disk that has the PFX certificate."
  default     = "../files/certificate.pfx"
}

variable "certificate_password" {
  description = "The PFX certificate password."
  default     = ""
}

variable "tenant_id" {
  default = ""
}

variable "subscription_id" {
  default = ""
}

variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

#------
# VMSS
#------ 
variable "service_name" {
  description = "Service name to describe resources of the service."
}

variable "service_image" {
  description = "Service image name from where your vmss is going to setup"
  default = ""
}

variable "instances_count" {
  description = "Number of instances that you want for vmss"
  default = 1
}

variable "vm_sku" {
  description = "Number of instances that you want for vmss"
  default = "Standard_F2"
}

variable "vm_admin_username" {
  description = "The username to login to the TFE Virtual Machines."
  default     = "adminuser"
}

variable "distribution" {
  description = "The images tested for the TFE submodule. (ubuntu or rhel)."
  #default     = "rhel"
  default     = "ubuntu"
}

#---------
# Network
#---------
variable "vnet_address_space" {
  description = "The virtual network address CIDR."
  default     = "10.0.0.0/16"
}

variable "public_ip_allowlist" {
  description = "List of public IP addresses to allow into the network. This is required for access to the PaaS services (AKV, SA, Postgres) and the bastion."
  type        = list
  default     = [
    #"x.x.x.x" # Your Default Public IP
  ]
}

#--------
# Locals
#--------
locals {
  hostname = join(".", [var.subdomain, var.domain])
  # These are the TFE images that have been tested. Select these with the var.distributon variable.
  ubuntu = {
    ubuntu = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    },
    rhel = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "7-RAW-CI"
      version   = "latest"
    }
  }
}