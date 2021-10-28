# How to start

In this example, we will deploy a VMSS (virtual machine scale set) with a Private Application Gateway and non running service. You can add your own service for testing. \
Other features that will be created are: Key vault, Postgres DB, Storage account, and DNS zone. \
In case you want to use a TFE backend, you can go to the **backend.tf** file and uncomment the code. Also, change it to meet your environment.

## What will you need ?

- Create a **.tfvars** file so you can change variables. There is an example at: **terraform.tfvars.example** you can copy and paste. (Remember to change values)

- You will need to import an existing Resource Group (RG). In case you want to create the RG, uncomment the first resource at **main.tf**.
This will create a RG with the specified values in .tfvars.

- Set you're ENV to connect to your azure RG. \
    (example: \
        export ARM_CLIENT_ID=00000000-0000-0000-0000-000000000000 \
        export ARM_SUBSCRIPTION_ID=00000000-0000-0000-0000-000000000000 \
        export ARM_TENANT_ID=00000000-0000-0000-0000-000000000000 \
        export ARM_CLIENT_SECRET=00000000-0000-0000-0000-000000000000)

- Be sure that the file "certificate.pfx" exists, it should be at [../files/certificate.pfx](../files/certificate.pfx). \
This is needed for tls certs.

- For DNS and tls to work, you will need to own a Domain. Mine was *companyname.site* purchased at Name.com. You can choose whatever provider you want.

- Finally run the commands:
    ```
        terraform init
        terraform validate
        terraform plan
        terraform apply
    ```

    There shouldn't be any issue. \
    Terraform validate will validate the syntax of the terraform code. \
    Terraform plan can bring issues for SSL when running several times, Make sure to use the staging url which is for testing and does not have rate limits.
