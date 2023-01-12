# Configuration du provider 
provider "azurerm" {
  features {}
}

#creation du groupe de ressource 
resource "azurerm_resource_group" "test" {
  name     = "Sirine_Amari"
  location = var.location
}

# Creation du réseau virtuel
resource "azurerm_virtual_network" "test" {
  name                = "test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

# Creation de sous_réseau
resource "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}


#Creation de la carte réseau
resource "azurerm_network_interface" "test" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "${var.name}-nic-ip-config"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"

  }
  depends_on = [
    azurerm_virtual_network.test,

  ]
}

resource "azurerm_network_security_group" "test" {
  name                = "${var.name}-security-group"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_network_security_rule" "test" {
  name                        = "${var.name}-security-rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "sirineamari1999"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "sirineamari"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}
#Creation de la machine virtuelle 
resource "azurerm_linux_virtual_machine" "test" {
  name                            = var.name
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  network_interface_ids           = [azurerm_network_interface.test.id]
  size                            = "Standard_B1s"
  computer_name                   = "mpssrvm"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "${var.name}-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

}