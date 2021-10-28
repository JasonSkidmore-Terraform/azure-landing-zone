# Starting Point
*It is important to mention that by "Landing Zone" we are not refering to the strategy. Instead, we refer to all network components which a vm or other similar feature could use.*

Here you will find 2 folders and 1 README file. \
In the **Examples** directory, as its name suggests, you will find 3 examples which the only difference is in the Load Balancer applied. \
In the **landing-zone** directory, you will find all modules covered in this repo.

### How to start?

Go to **Examples** directory and run any example there. Further instructions would be there. \
We recommend you to start by the simple Load Balancer.
Link: [Simple Load Balancer](Examples/example-public-load-balancer)


### Modules
Here is a list of all modules/features that we are covering at landing-zone, not only what a network needs, but also, other features.

- landing_zone:
    - Virtual Network
    - Subnet
    - SG (Security Group)
    - SG Rules
    - Public IP
    - Network Interface
    - Bastion

- key-vault:
    - Key Vault
    - Access Policies
    - Keyvault Key
    - Keyvault Secrets

- postgresql:
    - Potsgres Server
    - Database
    - Vnet rules
    - Firewall rules

- storage_account:
    - Storage Account
    - Container

- example-vmss:
    - Role Assignment for Keyvault
    - Access Policy for Keyvault
    - VMSS

- source-ami-packer-vmss:
    - Same that example-vmss but for custom Packer AMI and Rendered Data

- tls-acme:
    - All related with public tls certs

- tls-private:
    - All related with private tls certs

- public-load-balancer:
    - Load Balancer (LB)
    - Backend Address Pool
    - LB probes
    - LB rules

- public-application-gateway:
    - Same that LB but for App Gateway

- private-application-gateway:
    - Same that LB but for App Gateway (not using Public IPs)

- ssh:
    - SSH Keys


Go inside the Examples Directory for more details.

