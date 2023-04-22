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

module "acr_task" {
  source = "registry.terraform.io/libre-devops/container-registry-task/azurerm"

  location = module.rg.rg_location
  tags     = module.rg.rg_tags
  acr_id   = module.acr.acr_id

  acr_tasks = {
    "task1" = {
      is_system_task = false
      platform = {
        os = "Linux"
      }

      timer_trigger = {
        name     = "run-every-7-days"
        schedule = "0 13 * * 6"
        enabled  = true
      }

      encoded_step = {
        task_content = base64encode(<<EOF
version: v1.1.0
steps:
# Build target image
- build: -t {{.Run.Registry}}/hello-world:{{.Run.ID}} -f Dockerfile .
# Run image
- cmd: -t {{.Run.Registry}}/hello-world:{{.Run.ID}}
  id: test
  detach: true
  ports: ["8080:80"]
- cmd: docker stop test
# Push image
- push:
  - {{.Run.Registry}}/hello-world:{{.Run.ID}}
EOF
        )
        context_path         = "https://github.com/libre-devops/terraform-azurerm-container-registry-task#main"
        context_access_token = data.azurerm_key_vault_secret.mgmt_gh_pat.value
      }
    }
  }
}
