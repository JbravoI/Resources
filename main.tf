# Create a resource group
resource "azurerm_resource_group" "resourcegrp" {
  name     = var.rg_name
  location = var.rg_location
}

# #######################
#       Networking
##########################
#Vnet
resource "azurerm_virtual_network" "mainvnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resourcegrp.name
  resource_group_name = azurerm_resource_group.resourcegrp.location
}

#subnet
resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.resourcegrp.name
  virtual_network_name = azurerm_virtual_network.mainvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Interface
resource "azurerm_network_interface" "main_ni" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.resourcegrp.location
  resource_group_name = azurerm_resource_group.resourcegrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-pub_ip"
  resource_group_name = azurerm_resource_group.resourcegrp.name
  location            = azurerm_resource_group.resourcegrp.location
  allocation_method   = "Static"
}

################################
# Network Security group (NSG) #
################################
resource "azurerm_network_security_group" "main_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.resourcegrp.location
  resource_group_name = azurerm_resource_group.resourcegrp.name

  security_rule {
    name                       = var.name_of_Sec_rule
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#########################
# Virtual Machine       #
#########################
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.resourcegrp.location
  resource_group_name   = azurerm_resource_group.resourcegrp.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"
  # delete_os_disk_on_termination = true
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  user_data = <<EOF
#! /bin/bash
sudo  install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
EOF


}