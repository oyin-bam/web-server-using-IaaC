terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags     = var.tags 
}

# Create a virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Create a subnet in the virtual network
resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a network security group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Create a network security rule
resource "azurerm_network_security_rule" "allow-VMs" {
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.main.name
    name                       = "allow all other VMs"
    access                     = "Allow"
    direction                  = "Inbound"
    priority                   = 100
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
}

# Create a network security rule
resource "azurerm_network_security_rule" "deny-internet" {
    resource_group_name         = azurerm_resource_group.main.name
    network_security_group_name = azurerm_network_security_group.main.name
    name                        = "deny-internet-direct-access"
    access                      = "Deny"
    protocol                    = "*"
    priority                    = 120
    direction                   = "Inbound"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
    count               = var.vm-number > 4 ? 4 :var.vm-number
    name                = "${var.prefix}-nic-${count.index}"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    tags                = var.tags

    ip_configuration {
        name = "internal-nic-ip"
        subnet_id = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
  }
}

# Create a public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags                = var.tags
}

# Create a load balancer 
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.lb_sku
  tags                = var.tags

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

#Create a backend address pool for the lb
resource "azurerm_lb_backend_address_pool" "main" {
  name            = "${var.prefix}-lb-pool"
  loadbalancer_id = azurerm_lb.main.id
}

#Create an availability set
resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-av-set"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  platform_update_domain_count = var.vm-update-number
  platform_fault_domain_count  = var.vm-fault-number
  tags                         = var.tags

}

# Create virtual machines using the image deployed using packer
data "azurerm_image" "main" {
  name                = "bambamPackerVMImage"
  resource_group_name = "oyinbam-packer-rg"
}

resource "azurerm_linux_virtual_machine" "main" {
    count                           = var.vm-number > 5 ? 5 : var.vm-number
    name                            = "${var.prefix}-vm-${count.index}"
    resource_group_name             = azurerm_resource_group.main.name
    location                        = azurerm_resource_group.main.location
    size                            = "Standard_B1s"
    admin_username                  = "${var.username}"
    admin_password                  = "${var.password}"
    disable_password_authentication = false
    network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
    ]
    source_image_id                 = data.azurerm_image.main.id

    os_disk {
      name                 = "${var.prefix}-vm-disk-${count.index}"
      storage_account_type = "Standard_LRS"
      caching              = "ReadWrite"
    }
    tags = var.tags
}

#Create managed disks for the vm
resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-managed-disk"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  storage_account_type = "Standard_LRS"
  disk_size_gb         = "5"
  create_option        = "Empty"
  tags                 = var.tags
}