resource "azurerm_resource_group" "resourcegroup" {
  name = var.name
  location = var.location
  tags = {
    "diplomado" = "rgjibanez"
  }
}

resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "example-network"
  address_space       = ["12.0.0.0/16"]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.virtualnetwork.name
  address_prefixes     = ["12.0.2.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name = "public-ip-JiG4"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  allocation_method = "Static"
  tags = {
    diplomado = var.grupo
  }
}

resource "azurerm_network_interface" "networkinterface" {
  name                = "networkinterface"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "virtualmachine" {
  name                = "lmv-machineJiG4"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.networkinterface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
    computer_name = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"

    disable_password_authentication = false
}


resource "azurerm_container_registry" "acr" {
  name                = "containerRegistryJiG4"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  sku                 = "basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "kubernetescluster" {
  name                = "aksJiG4"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  dns_prefix          = "aks1"
  kubernetes_version = "1.19.6"

  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.subnet.id
    enable_auto_scaling = true
    max_count = 3
    min_count = 1
    max_pods = 80
  }


  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  role_based_access_control {
    enabled = true
  }

  service_principal {
  client_id             = "3aae846a-bd37-4552-8859-e75397b929c4"
  client_secret         = "SFx~R_-oswoY3M.NbCYr915-p6-rp17-6G"
  }
  
}


variable "name" {
  
}

variable "location" {
  
}

variable "grupo" {
  
}