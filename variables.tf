variable "name" {
  description = "Resource group name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "ip_adresses" {
  description = "The list of address spaces or ip adresses used by the virtual network, it looks like the CIDR BLOCK, but to many IPs"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  type        = list(string)
  default     = null
}

variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>"
  type        = string
  default     = null
}

variable "edge_zone" {
  description = "Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created"
  type        = string
  default     = null
}

variable "ddos_protection_plan_id" {
  description = "If defined will be attached this DDOs protection plan in virtual network ID"
  type        = string
  default     = null
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes"
  type        = number
  default     = null
}

variable "encryption_enforcement" {
  description = "Specifies if the encrypted Virtual Network allows VM that does not support encryption. Possible values are DropUnencrypted and AllowUnencrypted"
  type        = string
  default     = null
}

variable "vnet_dns_servers" {
  description = "List with DNS server to virtual network"
  type        = list(string)
  default     = null
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to virtual network"
  type        = map(any)
  default     = {}
}

variable "tags_nat_gateway_ip" {
  description = "Tags to static IP NAT gateway"
  type        = map(any)
  default     = {}
}

variable "tags_nat_gateway" {
  description = "Tags to static NAT gateway"
  type        = map(any)
  default     = {}
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Public IP Prefix should be located, required numeric, ex: [1, 2, 3]"
  type        = list(string)
  default     = ["1"]
}

variable "static_ip_nat_gateway_name" {
  description = "Specifies the name of the Public IP Prefix to NAT gateway resource"
  type        = string
  default     = null
}

variable "nat_gateway_name" {
  description = "Specifies the name of the NAT Gateway"
  type        = string
  default     = null
}

variable "nat_gateway_sku" {
  description = "The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard"
  type        = string
  default     = "Standard"
}

variable "idle_timeout_in_minutes" {
  description = "The idle timeout which should be used in minutes to NAT and internet gateways. Defaults to 4"
  type        = number
  default     = 4
}

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
  default = []
}

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
  default = []
}

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
