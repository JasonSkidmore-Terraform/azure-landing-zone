#--------
# Common
#--------
variable "resource_group_name" {
  description = "Name of the Resource Group to place resources in."
}

variable "location" {
  description = "The Azure region to deploy all infrastructure to."
}

variable "namespace" {
  description = "Name to assign to resources for easy organization."
}

variable "tags" {
  description = "The tags to apply to all resources."
  type        = map
  default     = {}
}

#-----------
# Key Vault
#-----------
variable "key_name" {
  description = "Azure Key Vault key name"
  default     = "generated-key"
}

variable "secrets" {
  description = "Secrets to save to the Azure Key Vault."
  type = list(object({
    name         = string
    content_type = string
    value        = string
  }))
  default = []
}

#---------
# Network
#---------
variable "subnet_id" {
  description = "The subnet id to place the External Services in."
}

variable "public_ip_allowlist" {
  description = "List of public IPs that need direct access to the PaaS in the Vnet (Optional)."
  type        = list(string)
  default     = []
}