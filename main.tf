resource "azurerm_network_interface" "main" {
  for_each  = var.components
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          =  "${each.key}-nic"
    subnet_id                     = "/subscriptions/3f2e42e1-ca06-4a99-8c56-be8d8ba306db/resourceGroups/denmark-east-rg/providers/Microsoft.Network/virtualNetworks/rhel10-vmVNET/subnets/rhel10-vmSubnet"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each  = var.components
  name                  = "${each.key}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  size               = each.value

  source_image_id = var.image_id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_password = "DevOps@123456"
  admin_username = "devops"

  disable_password_authentication = false

  secure_boot_enabled = true
  vtpm_enabled        = true

}

resource "azurerm_dns_a_record" "main" {
  for_each = var.components
  name                = "${each.key}-dev"
  zone_name           = "rdevopsb89.online"
  resource_group_name = var.resource_group_name
  ttl                 = 30
  records             = [azurerm_network_interface.main.private_ip_address]
}

