output "vnet" {
  description = "Virtual network"
  value       = azurerm_virtual_network.create_virtual_network
}

output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.create_virtual_network.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.create_virtual_network.name
}

output "vnet_location" {
  description = "Virtual network location"
  value       = azurerm_virtual_network.create_virtual_network.location
}

output "vnet_address_space" {
  description = "Virtual network address space"
  value       = azurerm_virtual_network.create_virtual_network.address_space
}

output "vnet_guid" {
  description = "Virtual network GUID"
  value       = azurerm_virtual_network.create_virtual_network.guid
}

output "vnet_dns_servers" {
  description = "Virtual DNS servers"
  value       = azurerm_virtual_network_dns_servers.create_vnet_dns_servers
}

output "public_subnets" {
  description = "Public subnets"
  value       = try(azurerm_subnet.create_public_subnets, null)
}

output "public_subnets_ids" {
  description = "Public subnets IDs"
  value       = try(azurerm_subnet.create_public_subnets[*].id, null)
}

output "private_subnets" {
  description = "Private subnets"
  value       = try(azurerm_subnet.create_private_subnets, null)
}

output "private_subnets_ids" {
  description = "Private subnets IDs"
  value       = try(azurerm_subnet.create_private_subnets[*].id, null)
}

output "static_ip_nat" {
  description = "Static IP NAT"
  value       = try(azurerm_public_ip.create_static_ip_nat, null)
}

output "nat_gateway" {
  description = "NAT gateway"
  value       = try(azurerm_nat_gateway.create_nat_gateway, null)
}

output "network_interface" {
  description = "Network interface"
  value       = try(azurerm_network_interface.create_network_interface_private_subnets, null)
}
