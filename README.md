# Azure Virtual Network and subnets for multiples accounts with Terraform module
* This module simplifies creating and configuring of Virtual Network and subnets across multiple accounts on Azure

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "azurerm" {
  alias   = "alias_profile_a"

  features {}
}

provider "azurerm" {
  alias   = "alias_profile_b"

  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}
```


## Features enable of Virtual Network and subnets configurations for this module:

- Virtual Network
- DNS servers
- Subnet
- Public IP
- NAT gateway
- Network interface

## Usage exemples


### Create Virtual Network and subnets publics and privates

```hcl
module "virtual_network_test" {
  source = source = "web-virtua-azure-multi-account-modules/vnet-full/azurerm"

  name                = "tf-network-full-vnet"
  resource_group_name = var.resource_name
  ip_adresses         = ["10.0.0.0/16"]

  public_subnets = [
    {
      address_prefixes = ["10.0.1.0/24"]
    },
    {
      address_prefixes = ["10.0.2.0/24"]
      delegation = {
        name            = "tf-public-subnet-2-delegation"
        service_name    = "Microsoft.Web/serverFarms"
        service_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    },
    {
      address_prefixes = ["10.0.10.0/24"]
    },
  ]

  private_subnets = [
    {
      address_prefixes = ["10.0.3.0/24"]
    },
    {
      address_prefixes = ["10.0.4.0/24"]
    },
  ]

  providers = {
    azurerm = azurerm.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| name | `string` | `-` | yes | Resource group name | `-` |
| resource_group_name | `string` | `-` | yes | Resource group name | `-` |
| ip_adresses | `list(string)` | `["10.0.0.0/16"]` | no | The list of address spaces or ip adresses used by the virtual network and subnets, it looks like the CIDR BLOCK, but to many IPs, default is 10.0.0.0/16 | `-` |
| dns_servers | `list(string)` | `-` | no | List of IP addresses of DNS servers | `-` |
| bgp_community | `string` | `-` | no | The BGP community attribute in format <as-number>:<community-value> | `-` |
| edge_zone | `string` | `null` | no | Specifies the Edge Zone within the Azure Region where this Virtual Network and subnets should exist. Changing this forces a new Virtual Network and subnets to be created | `-` |
| ddos_protection_plan_id | `string` | `null` | no | If defined will be attached this DDOs protection plan in virtual network and subnets ID | `-` |
| flow_timeout_in_minutes | `number` | `null` | no | The flow timeout in minutes for the Virtual Network and subnets, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes | `-` |
| encryption_enforcement | `string` | `null` | no | Specifies if the encrypted Virtual Network and subnets allows VM that does not support encryption. Possible values are DropUnencrypted and AllowUnencrypted | `*`AllowUnencrypted <br> `*`DropUnencrypted |
| vnet_dns_servers | `list(string)` | `-` | no | List of IP addresses of DNS servers | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags | `map(any)` | `{}` | no | Tags to virtual network and subnets | `-` |
| tags_nat_gateway_ip | `map(any)` | `{}` | no | Tags to static IP NAT gateway | `-` |
| tags_nat_gateway | `map(any)` | `{}` | no | Tags to static NAT gateway | `-` |
| zones | `list(string)` | `["1"]v` | no | Specifies a list of Availability Zones in which this Public IP Prefix should be located, required numeric, ex: [1, 2, 3] | `-` |
| nat_gateway_name | `string` | `null` | no | Specifies the name of the NAT Gateway | `-` |
| nat_gateway_sku | `string` | `Standard` | no | The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard | `*`Standard |
| idle_timeout_in_minutes | `number` | `4` | no | The idle timeout which should be used in minutes to NAT and internet gateways. Defaults to 4 | `-` |
| public_subnets | `list(object)` | `[]` | no | Define the public subnets configuration | `-` |
| private_subnets | `list(object)` | `[]` | no | Define the private subnets configuration | `-` |
| static_ip_nat_configuration | `object` | `object` | no | Static IP NAT configuration | `-` |

* Model of public_subnets variable
```hcl
variable "public_subnets" {
  description = "Define the public subnets configuration"
  type = list(object({
    address_prefixes              = list(string)               # The list of address spaces or ip adresses used by the virtual network, it looks like the CIDR BLOCK, but to many IPs
    name                          = optional(string)           # Optional name
    service_endpoints             = optional(list(string), []) # The list of Service endpoints to associate with the subnet, the values can be Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web
    service_endpoint_policy_ids   = optional(list(string))     # The list of IDs of Service Endpoint Policies to associate with the subnet
    private_link_endpoint_enabled = optional(bool, true)       # Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true
    private_link_service_enabled  = optional(bool, true)       # Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true
    delegation = optional(object({
      name            = string                 # A name for this delegation
      service_name    = string                 # The name of service to delegate to. Possible values are GitHub.Network/networkSettings, look doc for more itens
      service_actions = optional(list(string)) # A list of Actions which should be delegated. This list is specific to the service to delegate to. Possible values are Microsoft.Network/networkinterfaces/*, Microsoft.Network/publicIPAddresses/join/action, look doc for more itens
    }))
  }))
  default = [
    {
      address_prefixes = ["10.0.1.0/24"]
    },
    {
      address_prefixes = ["10.0.2.0/24"]
      delegation = {
        name            = "tf-public-subnet-2-delegation"
        service_name    = "Microsoft.Web/serverFarms"
        service_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    },
    {
      address_prefixes = ["10.0.10.0/24"]
    },
  ]
}
```

* Model of private_subnets variable
```hcl
variable "private_subnets" {
  description = "Define the private subnets configuration"
  type = list(object({
    address_prefixes              = list(string)
    name                          = optional(string)
    service_endpoints             = optional(list(string), [])
    service_endpoint_policy_ids   = optional(list(string))
    private_link_endpoint_enabled = optional(bool, true)
    private_link_service_enabled  = optional(bool, true)
    delegation = optional(object({
      name            = string
      service_name    = string
      service_actions = optional(list(string))
    }))
    network_interface_config = optional(object({
      auxiliary_mode                                     = optional(string)
      auxiliary_sku                                      = optional(string)
      dns_servers                                        = optional(list(string))
      edge_zone                                          = optional(string)
      enable_ip_forwarding                               = optional(bool)
      enable_accelerated_networking                      = optional(bool)
      internal_dns_name_label                            = optional(string)
      tags                                               = optional(map(any), {})
      public_ip_address_id                               = optional(string)
      gateway_load_balancer_frontend_ip_configuration_id = optional(string)
      private_ip_address_version                         = optional(string)
      primary                                            = optional(bool)
      private_ip_address                                 = optional(string)
    }))
  }))
  default = [
    {
      address_prefixes = ["10.0.3.0/24"]
    },
    {
      address_prefixes = ["10.0.4.0/24"]
    },
  ]
}
```

* Model of static_ip_nat_configuration variable
```hcl
variable "static_ip_nat_configuration" {
  description = "Static IP NAT configuration"
  type = object({
    allocation_method       = optional(string)
    sku                     = optional(string)
    ddos_protection_mode    = optional(string)
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    edge_zone               = optional(string)
    idle_timeout_in_minutes = optional(number)
    ip_version              = optional(string)
    public_ip_prefix_id     = optional(string)
    reverse_fqdn            = optional(string)
    sku_tier                = optional(string)
    ip_tags                 = optional(map(any), {})
    tags                    = optional(map(any), {})
  })
  default = {
    allocation_method = "Static"
    sku               = "Standard"
  }
}
```


## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network.create_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_dns_servers.create_vnet_dns_servers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |
| [azurerm_subnet.create_public_subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.create_private_subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_public_ip.create_static_ip_nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_nat_gateway_public_ip_association.create_nat_gateway_associated_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association.html) | resource |
| [azurerm_nat_gateway.create_nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_subnet_nat_gateway_association.create_nat_gateway_associated_public_subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_network_interface.create_network_interface_private_subnets](https://www.google.com/search?channel=fs&client=ubuntu&q=azurerm_network_interface) | resource |


## Outputs

| Name | Description |
|------|-------------|
| `vnet` | Virtual network and subnets |
| `vnet_id` | Virtual network and subnets ID |
| `vnet_name` | Virtual network and subnets name |
| `vnet_location` | Virtual network and subnets location |
| `vnet_address_space` | Virtual network address space |
| `vnet_guid` | Virtual network GUID |
| `vnet_dns_servers` | Virtual DNS servers |
| `public_subnets` | Public subnets |
| `public_subnets_ids` | Public subnets IDs |
| `private_subnets` | Private subnets |
| `private_subnets_ids` | Private subnets IDs |
| `static_ip_nat` | Static IP NAT |
| `nat_gateway` | NAT gateway |
| `network_interface` | Network interface |
