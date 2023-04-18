
```hcl
module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "acr" {
  source = "registry.terraform.io/libre-devops/azure-container-registry/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  acr_name      = "acr${var.short}${var.loc}${terraform.workspace}01"
  sku           = "Premium"
  identity_type = "SystemAssigned"
  admin_enabled = true

  settings = {}
}

// This module does not consider for CMKs and allows the users to manually set bypasses
#checkov:skip=CKV2_AZURE_1:CMKs are not considered in this module
#checkov:skip=CKV2_AZURE_18:CMKs are not considered in this module
#checkov:skip=CKV_AZURE_33:Storage logging is not configured by default in this module
#tfsec:ignore:azure-storage-queue-services-logging-enabled tfsec:ignore:azure-storage-allow-microsoft-service-bypass #tfsec:ignore:azure-storage-default-action-deny
module "sa" {
  source = "registry.terraform.io/libre-devops/storage-account/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  storage_account_name            = "st${var.short}${var.loc}${terraform.workspace}01"
  access_tier                     = "Hot"
  identity_type                   = "SystemAssigned"
  allow_nested_items_to_be_public = true

  storage_account_properties = {

    // Set this block to enable network rules
    network_rules = {
      default_action = "Allow"
    }

    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      default_service_version  = "2020-06-12"
      last_access_time_enabled = false

      deletion_retention_policies = {
        days = 10
      }

      container_delete_retention_policy = {
        days = 10
      }
    }

    routing = {
      publish_internet_endpoints  = false
      publish_microsoft_endpoints = true
      choice                      = "MicrosoftRouting"
    }
  }
}


locals {
  # These may depend on the project so I have tried to template them out
  now                      = timestamp()
  seven_days_from_now      = timeadd(timestamp(), "168h")
}

resource "azurerm_storage_container" "storage_container" {
  name                 = "blobcontainer"
  storage_account_name = module.sa.sa_name
}

resource "azurerm_storage_blob" "storage_blob" {
  name                   = "Dockerfile"
  storage_account_name   = module.sa.sa_name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
  content_md5            = filemd5("Dockerfile")
  source                 = "Dockerfile"
}

data "azurerm_storage_account_blob_container_sas" "storage_account_blob_container_sas" {
  connection_string = module.sa.sa_primary_connection_string
  container_name    = azurerm_storage_container.storage_container.name

  start  = local.now
  expiry = local.seven_days_from_now

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

module "acr_task" {
  source = "../../"

  location  = module.rg.rg_location
  tags      = module.rg.rg_tags
  acr_id    = module.acr.acr_id

  acr_tasks = {
    "task1" = {
      is_system_task = false
      platform = {
        os = "Linux"
      }
      docker_step = {
        dockerfile_path = "Dockerfile"
        context_path         = "${module.sa.sa_primary_blob_endpoint}/${azurerm_storage_container.storage_container.name}/${azurerm_storage_blob.storage_blob.name}"
        context_access_token = data.azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas.sas
        image_names          = ["ldo-alpine:latest"]
      }
    }
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.52.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acr"></a> [acr](#module\_acr) | registry.terraform.io/libre-devops/azure-container-registry/azurerm | n/a |
| <a name="module_acr_task"></a> [acr\_task](#module\_acr\_task) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | registry.terraform.io/libre-devops/rg/azurerm | n/a |
| <a name="module_sa"></a> [sa](#module\_sa) | registry.terraform.io/libre-devops/storage-account/azurerm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_blob.storage_blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_client_config.current_creds](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.mgmt_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.mgmt_local_admin_pwd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.mgmt_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_ssh_public_key.mgmt_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/ssh_public_key) | data source |
| [azurerm_storage_account_blob_container_sas.storage_account_blob_container_sas](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_blob_container_sas) | data source |
| [azurerm_user_assigned_identity.mgmt_user_assigned_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | This is passed as an environment variable, it is for the shorthand environment tag for resource.  For example, production = prod | `string` | `"dev"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The shorthand name of the Azure location, for example, for UK South, use uks.  For UK West, use ukw. Normally passed as TF\_VAR in pipeline | `string` | `"euw"` | no |
| <a name="input_short"></a> [short](#input\_short) | This is passed as an environment variable, it is for a shorthand name for the environment, for example hello-world = hw | `string` | `"ldo"` | no |

## Outputs

No outputs.
