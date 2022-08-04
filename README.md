# Agi

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.
This project guides you to deploying a scalable web server in azure 

### Getting Started
1. Clone this repository

2. Ensure all depemdencies are installed

3. Create your infrastructure as code

4. Deploy your infrastructure

### Dependencies
1. Install any simple text editor
2. Create an [Azure Account](https://portal.azure.com) 
3. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
4. Install [Packer](https://www.packer.io/downloads)
5. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Login to the azure portal, go to azure active drectory and register an application with a name of preference
take note of the client ID, Tenant ID, subscription ID. Also, create a client secret and take note of the secret value (immediately). These values would be placed in your .env file and would be accessed by the parker file
2. to create the policy (default here ensures all resources have tags before they can be created). login at the cli using "az login". Then run the following commands.
        az policy definition create --name <policyname> --rules <filename>
        az policy assignment create --policy <policyname>

3. Create the image to be deployed into the created VM's using packer. run this command
        packer build

4. You can choose to edit the default values and names of te variables from the variables.tf file

5. Deploy the infrastructure as code using terraform
        terraform plan -out solution.plan
        terraform apply solution.plan

6. Confirm resources created from the cli using:
        terraform show 
    or go to the azure portal, log on and check created resources

### Output
    Confirm resources created from the cli using:
            terraform show 
    or go to the azure portal, log on and check created resources