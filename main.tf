locals {
  tags_virtual_network = {
    "tf-name" = var.name
    "tf-type" = "vnet"
  }

  tags_ip_nat = {
    "tf-name" = var.static_ip_nat_gateway_name != null ? var.static_ip_nat_gateway_name : "${var.name}-static-ip-nat-prefix"
    "tf-type" = "static-ip"
  }

  tags_nat_gateway = {
    "tf-name" = var.nat_gateway_name != null ? var.nat_gateway_name : "${var.name}-ngtw"
    "tf-type" = "ngtw"
  }
}

data "azurerm_resource_group" "get_resource_group" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "create_virtual_network" {
  name                    = var.name
  resource_group_name     = data.azurerm_resource_group.get_resource_group.name
  location                = data.azurerm_resource_group.get_resource_group.location
  address_space           = var.ip_adresses
  dns_servers             = var.dns_servers
  bgp_community           = var.bgp_community
  edge_zone               = var.edge_zone
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  tags                    = merge(var.tags, var.use_tags_default ? local.tags_virtual_network : {})

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id != null ? [1] : []

    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  dynamic "encryption" {
    for_each = var.encryption_enforcement != null ? [1] : []

    content {
      enforcement = var.encryption_enforcement
    }
  }
}

resource "azurerm_virtual_network_dns_servers" "create_vnet_dns_servers" {
  count = var.vnet_dns_servers == null ? 0 : 1

  virtual_network_id = azurerm_virtual_network.create_virtual_network.id
  dns_servers        = var.vnet_dns_servers
}

# ----------------------------------------------------------------#
# Public Subnets
# ----------------------------------------------------------------#
resource "azurerm_subnet" "create_public_subnets" {
  count = length(var.public_subnets)

  resource_group_name                           = data.azurerm_resource_group.get_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.create_virtual_network.name
  name                                          = var.public_subnets[count.index].name != null ? var.public_subnets[count.index].name : "${var.name}-public-subnet-${count.index + 1}"
  address_prefixes                              = var.public_subnets[count.index].address_prefixes
  service_endpoints                             = var.public_subnets[count.index].service_endpoints
  service_endpoint_policy_ids                   = var.public_subnets[count.index].service_endpoint_policy_ids
  private_endpoint_network_policies_enabled     = var.public_subnets[count.index].private_link_endpoint_enabled
  private_link_service_network_policies_enabled = var.public_subnets[count.index].private_link_service_enabled

  dynamic "delegation" {
    for_each = var.public_subnets[count.index].delegation != null ? [1] : []

    content {
      name = var.public_subnets[count.index].delegation.name

      service_delegation {
        name    = var.public_subnets[count.index].delegation.service_name
        actions = var.public_subnets[count.index].delegation.service_actions
      }
    }
  }
}

resource "azurerm_public_ip" "create_static_ip_nat" {
  name                    = var.static_ip_nat_gateway_name != null ? var.static_ip_nat_gateway_name : "${var.name}-static-ip-nat"
  resource_group_name     = data.azurerm_resource_group.get_resource_group.name
  location                = data.azurerm_resource_group.get_resource_group.location
  zones                   = var.zones
  allocation_method       = var.static_ip_nat_configuration.allocation_method
  sku                     = var.static_ip_nat_configuration.sku
  ddos_protection_mode    = var.static_ip_nat_configuration.ddos_protection_mode
  ddos_protection_plan_id = var.static_ip_nat_configuration.ddos_protection_plan_id
  domain_name_label       = var.static_ip_nat_configuration.domain_name_label
  edge_zone               = var.static_ip_nat_configuration.edge_zone
  idle_timeout_in_minutes = var.static_ip_nat_configuration.idle_timeout_in_minutes
  ip_tags                 = var.static_ip_nat_configuration.ip_tags
  ip_version              = var.static_ip_nat_configuration.ip_version
  public_ip_prefix_id     = var.static_ip_nat_configuration.public_ip_prefix_id
  reverse_fqdn            = var.static_ip_nat_configuration.reverse_fqdn
  sku_tier                = var.static_ip_nat_configuration.sku_tier
  tags                    = var.static_ip_nat_configuration.tags
}

resource "azurerm_nat_gateway_public_ip_association" "create_nat_gateway_associated_ip" {
  nat_gateway_id       = azurerm_nat_gateway.create_nat_gateway.id
  public_ip_address_id = azurerm_public_ip.create_static_ip_nat.id
}

resource "azurerm_nat_gateway" "create_nat_gateway" {
  name                    = var.nat_gateway_name != null ? var.nat_gateway_name : "${var.name}-ngtw"
  resource_group_name     = data.azurerm_resource_group.get_resource_group.name
  location                = data.azurerm_resource_group.get_resource_group.location
  sku_name                = var.nat_gateway_sku
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones
  tags                    = merge(var.tags_nat_gateway, var.use_tags_default ? local.tags_nat_gateway : {})
}

resource "azurerm_subnet_nat_gateway_association" "create_nat_gateway_associated_public_subnets" {
  count = length(azurerm_subnet.create_public_subnets)

  subnet_id      = azurerm_subnet.create_public_subnets[count.index].id
  nat_gateway_id = azurerm_nat_gateway.create_nat_gateway.id
}

# ----------------------------------------------------------------#
# Private Subnets
# ----------------------------------------------------------------#
resource "azurerm_subnet" "create_private_subnets" {
  count = length(var.private_subnets)

  resource_group_name                           = data.azurerm_resource_group.get_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.create_virtual_network.name
  name                                          = var.private_subnets[count.index].name != null ? var.private_subnets[count.index].name : "${var.name}-private-subnet-${count.index + 1}"
  address_prefixes                              = var.private_subnets[count.index].address_prefixes
  service_endpoints                             = var.private_subnets[count.index].service_endpoints
  service_endpoint_policy_ids                   = var.private_subnets[count.index].service_endpoint_policy_ids
  private_endpoint_network_policies_enabled     = var.private_subnets[count.index].private_link_endpoint_enabled
  private_link_service_network_policies_enabled = var.private_subnets[count.index].private_link_service_enabled

  dynamic "delegation" {
    for_each = var.private_subnets[count.index].delegation != null ? [1] : []

    content {
      name = var.private_subnets[count.index].delegation.name

      service_delegation {
        name    = var.public_subnets[count.index].delegation.service_name
        actions = var.public_subnets[count.index].delegation.service_actions
      }
    }
  }
}

resource "azurerm_network_interface" "create_network_interface_private_subnets" {
  count = length(azurerm_subnet.create_private_subnets)

  name                          = "${azurerm_subnet.create_private_subnets[count.index].name}-net-interface"
  resource_group_name           = data.azurerm_resource_group.get_resource_group.name
  location                      = data.azurerm_resource_group.get_resource_group.location
  auxiliary_mode                = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.auxiliary_mode : null
  auxiliary_sku                 = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.auxiliary_sku : null
  dns_servers                   = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.dns_servers : null
  edge_zone                     = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.edge_zone : null
  enable_ip_forwarding          = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.enable_ip_forwarding : null
  enable_accelerated_networking = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.enable_accelerated_networking : null
  internal_dns_name_label       = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.internal_dns_name_label : null
  tags                          = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.tags : null

  ip_configuration {
    subnet_id                                          = azurerm_subnet.create_private_subnets[count.index].id
    name                                               = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.name : "internal"
    private_ip_address_allocation                      = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.private_ip_address_allocation : "Dynamic"
    public_ip_address_id                               = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.public_ip_address_id : null
    gateway_load_balancer_frontend_ip_configuration_id = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.gateway_load_balancer_frontend_ip_configuration_id : null
    private_ip_address_version                         = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.private_ip_address_version : null
    primary                                            = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.primary : null
    private_ip_address                                 = var.private_subnets[count.index].network_interface_config != null ? var.private_subnets[count.index].network_interface_config.private_ip_address : null
  }
}
