
# # Creates resource group
# resource "azurerm_resource_group" "RG" {
#   name     = var.resource_group_name
#   location = var.location
# }

#-------------
# TLS Certs
#-------------
module "tls" {
  source               = "../../landing-zone/modules/tls-acme" # Let's Encrypt
  # source               = "../../landing-zone/modules/tls-private" # Self-Signed
  domain               = var.domain
  hostname             = local.hostname
  certificate_path     = var.certificate_path
  certificate_password = var.certificate_password
  resource_group_name  = var.resource_group_name
  client_id            = var.client_id
  client_secret        = var.client_secret
  subscription_id      = var.subscription_id
  tenant_id            = var.tenant_id
}

#-------------------
# Networking for RG
#-------------------
module "landing_zone" {
  source = "../../landing-zone/modules/landing_zone"

  resource_group_name = var.resource_group_name
  location            = var.location

  namespace           = var.namespace

  vnet_address_space  = var.vnet_address_space

  public_ip_allowlist = var.public_ip_allowlist

  subnet_address_spaces = [
    {
      name          = var.namespace
      address_space = cidrsubnet(var.vnet_address_space, 8, 0) # Bastion
    }
    ,
    {
      address_space = cidrsubnet(var.vnet_address_space, 8, 1) #  postgresDB, StorageAccount and Keyvault
    }
    ,
    {
      address_space = cidrsubnet(var.vnet_address_space, 8, 2) # VM
    }
    ,
    {
      address_space = cidrsubnet(var.vnet_address_space, 8, 3) # Load Balancer
    }
  ]

  bastion = {
    username   = var.vm_admin_username
    public_key = module.ssh_keys.ssh_public_key
  }

  tags = var.tags
}


#-------------
# SSH Keys
#-------------
module "ssh_keys" {
  source = "../../landing-zone/modules/ssh"

  # path_to_pem = "<Pathtofile>" # example: "./tfe_rsa.pem"
  # path_to_pub = "<Pathtofile>" # example: "./tfe_rsa.pub"
}

#-------------
# Postgres DB
#-------------
module "postgres-DB" {
  source = "../../landing-zone/modules/postgresql"

  resource_group_name = var.resource_group_name
  location            = var.location
  namespace           = var.namespace
  subnet_id           = module.landing_zone.networking.subnet_ids[1]
  public_ip_allowlist = var.public_ip_allowlist

  tags = var.tags
}

#-----------------
# Storage Account
#-----------------
module "storage-account" {
  source = "../../landing-zone/modules/storage_account"

  resource_group_name  = var.resource_group_name
  location             = var.location
  namespace            = var.namespace
  subnet_id            = module.landing_zone.networking.subnet_ids[1]
  public_ip_allowlist  = var.public_ip_allowlist

  storage_account = {
    tier = "Standard" # Valid "tier" [Standard, Premium]
    type = "LRS"      # Valid "type" [LRS, GRS, RAGRS and ZRS]
  }

  tags = var.tags
}

#-------------
# Key Vault
#-------------
module "key-vault" {
  source = "../../landing-zone/modules/key-vault"

  resource_group_name = var.resource_group_name
  location            = var.location
  namespace           = var.namespace
  subnet_id           = module.landing_zone.networking.subnet_ids[1]
  public_ip_allowlist = var.public_ip_allowlist

  # SECRETS EXAMPLE
  # secrets = [
  #   {
  #     name         = "replicated-config"
  #     content_type = "application/json"
  #     value        = module.configs.key_vault_secrets.replicated_conf
  #   },
  #   {
  #     name         = "replicated-tfe-config"
  #     content_type = "application/json"
  #     value        = module.configs.key_vault_secrets.replicated_tfe_conf
  #   },
  #   {
  #     name         = "replicated-license"
  #     content_type = "binary/base64"
  #     value        = module.configs.key_vault_secrets.license_b64
  #   },
  #   {
  #     name         = "tls-cert"
  #     content_type = "pem"
  #     value        = module.configs.key_vault_secrets.tls_cert
  #   },
  #   {
  #     name         = "tls-key"
  #     content_type = "pem"
  #     value        = module.configs.key_vault_secrets.tls_key
  #   }
  # ]

  tags = var.tags
}

#--------------
# VMSS example
#--------------
module "vmss-service" {
  source = "../../landing-zone/modules/example-vmss"

  resource_group_name = var.resource_group_name
  location            = var.location
  service_name        = var.service_name
  service_image       = var.service_image  # Packer AMI Name
  namespace           = var.namespace
  vm_sku              = var.vm_sku
  instances_count     = var.instances_count
  subnet_id           = module.landing_zone.networking.subnet_ids[2]

  # startup_script = module.configs.startup_script
  os_image      = local.ubuntu[var.distribution]
  keyvault = {
    enabled = true
    id      = module.key-vault.keyvault.id
  }

  vm_user = {
    username   = var.vm_admin_username
    public_key = module.ssh_keys.ssh_public_key
  }

  lb = {
    type                    = "AAG"
    backend_address_pool_id = module.load-balancer.backend_address_pool_id
    health_probe_id         = module.load-balancer.health_probe_id
  }

  tags = var.tags
}

#---------------
# Load Balancer
#---------------
module "load-balancer" {
  source = "../../landing-zone/modules/public-application-gateway"

  resource_group_name = var.resource_group_name
  location            = var.location
  namespace           = var.namespace
  hostname            = local.hostname # "localhost"
  subnet_id           = module.landing_zone.networking.subnet_ids[3]

  tls = {
    name = module.tls.name
    pfx_b64      = module.tls.pfx_b64
    pfx_password = module.tls.password
  }

  tags = var.tags
}

#-----------------
# Create DNS Zone
#-----------------
# (comment if you already have a DNS Zone and just create the records instead)
resource "azurerm_dns_zone" "DNS" {
  name                = var.domain
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_zone" "subdomain" {
  name                = local.hostname
  resource_group_name = var.resource_group_name
}

# resource "azurerm_private_dns_zone" "example-private" {
#   name                = var.domain
#   resource_group_name = var.resource_group_name
# }

# Do not comment
# resource "azurerm_dns_a_record" "DNS" {
#   name                = var.subdomain
#   zone_name           = azurerm_dns_zone.DNS.name # Uncomment if DNS zone managed by terraform
#   # zone_name           = var.domain                # Use this if DNS zone not managed by terraform
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_public_ip.vm.ip_address]
# }


#-------------
# outputs
#-------------
output "postgres_pass" {
  value = {
    postgres_pass = module.postgres-DB.postgres_config.password
  }
}

data "azurerm_public_ip" "bastion" {
  name                = module.landing_zone.networking.pip
  resource_group_name = module.landing_zone.vm.resource_group_name

  depends_on = [ 
    module.landing_zone
   ]
}

output "domain_name_label" {
  value = data.azurerm_public_ip.bastion.domain_name_label
}

output "public_ip_address" {
  value = data.azurerm_public_ip.bastion.ip_address
}

output "ssh-addr-bastion" {
 value = <<SSH

   Connect to your virtual machine via SSH:

   $ ssh ${module.landing_zone.vm.admin_user}@${data.azurerm_public_ip.bastion.ip_address}
SSH
}