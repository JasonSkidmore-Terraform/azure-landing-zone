# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version         = "=2.20.0"

  features {}
}

provider "acme" {
  // server_url = "https://acme-v02.api.letsencrypt.org/directory" #use this for production as it has rate limits
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory" #staging - no rate limits
}
