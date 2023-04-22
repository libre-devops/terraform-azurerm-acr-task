## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry_task.acr_task](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task) | resource |
| [azurerm_container_registry_task_schedule_run_now.schedule_run_now](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task_schedule_run_now) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_id"></a> [acr\_id](#input\_acr\_id) | The ID of the ACR this tasks is being made for | `string` | n/a | yes |
| <a name="input_acr_tasks"></a> [acr\_tasks](#input\_acr\_tasks) | The ACR tasks block where each key is the name of the task | `any` | n/a | yes |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Specifies a list of user managed identity ids to be assigned to the VM. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The Managed Service Identity Type of this Virtual Machine. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_schedule_task_run_now"></a> [schedule\_task\_run\_now](#input\_schedule\_task\_run\_now) | Whether a task should be scheduled for now, defaults to true | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_task_id"></a> [acr\_task\_id](#output\_acr\_task\_id) | The ID of the created task |
| <a name="output_acr_task_identity"></a> [acr\_task\_identity](#output\_acr\_task\_identity) | The identity block |
| <a name="output_acr_task_name"></a> [acr\_task\_name](#output\_acr\_task\_name) | The name of the created task |
