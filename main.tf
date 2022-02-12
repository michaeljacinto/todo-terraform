resource "azurerm_resource_group" "todo-app-rg" {
  name     = "todo_app_rg"
  location = "West US 2"
}

resource "random_id" "todo-app-id" {
  byte_length = 3
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

locals {
  myip                = chomp(data.http.myip.body)
  provisioning_script = "provision.sh"
}

resource "azurerm_virtual_network" "todo-vnet" {
  name                = "todo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.todo-app-rg.location
  resource_group_name = azurerm_resource_group.todo-app-rg.name
}

resource "azurerm_subnet" "todo-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.todo-app-rg.name
  virtual_network_name = azurerm_virtual_network.todo-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "todo-nsg" {
  name                = "todo_nsg"
  location            = azurerm_resource_group.todo-app-rg.location
  resource_group_name = azurerm_resource_group.todo-app-rg.name
}

resource "azurerm_network_security_rule" "nsg-80" {
  name                        = "HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.todo-app-rg.name
  network_security_group_name = azurerm_network_security_group.todo-nsg.name
}

resource "azurerm_network_security_rule" "nsg-443" {
  name                        = "HTTPS"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.todo-app-rg.name
  network_security_group_name = azurerm_network_security_group.todo-nsg.name
}

resource "azurerm_network_security_rule" "nsg-ssh" {
  name                        = "SSH"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = local.myip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.todo-app-rg.name
  network_security_group_name = azurerm_network_security_group.todo-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  subnet_id                 = azurerm_subnet.todo-subnet.id
  network_security_group_id = azurerm_network_security_group.todo-nsg.id
}

resource "azurerm_public_ip" "todo-ip" {
  name                    = "public-todo-ip"
  location                = azurerm_resource_group.todo-app-rg.location
  resource_group_name     = azurerm_resource_group.todo-app-rg.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  domain_name_label       = "todoapp${random_id.todo-app-id.hex}"
}

resource "azurerm_network_interface" "todo-nic" {
  name                = "todo-nic"
  location            = azurerm_resource_group.todo-app-rg.location
  resource_group_name = azurerm_resource_group.todo-app-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.todo-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.todo-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "todo-vm" {
  name                            = "todo-vm-machine"
  resource_group_name             = azurerm_resource_group.todo-app-rg.name
  location                        = azurerm_resource_group.todo-app-rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.todo-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "centos-std-provisioning" {

  name                 = azurerm_linux_virtual_machine.todo-vm.name
  virtual_machine_id   = azurerm_linux_virtual_machine.todo-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  timeouts {
    create = "60m"
  }

  protected_settings = <<SETTINGS
  {
  "script": "${base64encode(templatefile("${path.module}/${local.provisioning_script}.tmpl", {
  mysql_host          = var.mysql_host,
  mysql_user          = var.mysql_user,
  mysql_password      = var.mysql_password,
  mysql_root_password = var.mysql_root_password,
  mysql_database      = var.mysql_database,
  email               = var.email,
  domain              = azurerm_public_ip.todo-ip.fqdn
})
)
}"
  }
  SETTINGS
}
