resource "azurerm_container_registry_task" "acr_task" {
  for_each              = var.acr_tasks
  name                  = each.key
  container_registry_id = var.acr_id
  agent_pool_name       = try(each.value.agent_pool_name, null)
  enabled               = try(each.value.enabled, true)
  log_template          = try(each.value.log_template, null)
  tags                  = var.tags
  is_system_task        = try(each.value.is_system_task, null)


  dynamic "agent_setting" {
    for_each = lookup(var.acr_tasks[each.key], "agent_setting", {}) != {} ? [1] : []
    content {
      cpu = lookup(var.acr_tasks[each.key].agent_setting, "cpu", null)
    }
  }

  dynamic "authentication" {
    for_each = lookup(var.acr_tasks[each.key], "authentication", {}) != {} ? [1] : []
    content {
      token             = lookup(var.acr_tasks[each.key].authentication, "token", null)
      token_type        = lookup(var.acr_tasks[each.key].authentication, "token_type", null)
      expire_in_seconds = lookup(var.acr_tasks[each.key].authentication, "expire_in_seconds", null)
      refresh_token     = lookup(var.acr_tasks[each.key].authentication, "refresh_token", null)
      scope             = lookup(var.acr_tasks[each.key].authentication, "scope", null)
    }
  }

  dynamic "base_image_trigger" {
    for_each = lookup(var.acr_tasks[each.key], "base_image_trigger", {}) != {} ? [1] : []
    content {
      name                        = lookup(var.acr_tasks[each.key].base_time_trigger, "name", null)
      type                        = lookup(var.acr_tasks[each.key].base_time_trigger, "type", null)
      enabled                     = lookup(var.acr_tasks[each.key].base_time_trigger, "enabled", null)
      update_trigger_endpoint     = lookup(var.acr_tasks[each.key].base_time_trigger, "update_trigger_endpoint", null)
      update_trigger_payload_type = lookup(var.acr_tasks[each.key].base_time_trigger, "update_trigger_payload_type", null)
    }
  }

  dynamic "custom" {
    for_each = lookup(var.acr_tasks[each.key], "custom", {}) != {} ? [1] : []
    content {
      login_server = lookup(var.acr_tasks[each.key].custom, "login_server", null)
      identity     = lookup(var.acr_tasks[each.key].custom, "identity", null)
      username     = lookup(var.acr_tasks[each.key].custom, "username", null)
      password     = lookup(var.acr_tasks[each.key].custom, "password", null)
    }
  }

  dynamic "docker_step" {
    for_each = lookup(var.acr_tasks[each.key], "docker_step", {}) != {} ? [1] : []
    content {
      context_access_token = lookup(var.acr_tasks[each.key].docker_step, "context_access_token", null)
      context_path         = lookup(var.acr_tasks[each.key].docker_step, "context_path", null)
      dockerfile_path      = lookup(var.acr_tasks[each.key].docker_step, "dockerfile_path", null)
      arguments            = lookup(var.acr_tasks[each.key].docker_step, "arguments", {})
      secret_arguments     = lookup(var.acr_tasks[each.key].docker_step, "secret_arguments", null)
      image_names          = lookup(var.acr_tasks[each.key].docker_step, "image_names", [])
      cache_enabled        = lookup(var.acr_tasks[each.key].docker_step, "cache_enabled", null)
      push_enabled         = lookup(var.acr_tasks[each.key].docker_step, "push_enabled", null)
      target               = lookup(var.acr_tasks[each.key].docker_step, "target", null)
    }
  }

  #  dynamic "encoded_step" {
  #    for_each = lookup(var.acr_tasks[each.key], "encoded_step",  {}) != {} ? [1] : []
  #    content {
  #      task_content = lookup(var.acr_tasks[each.key].encoded_step, "task_content", null)
  #      context_access_token = lookup(var.acr_tasks[each.key].encoded_step, "context_access_token", null)
  #      context_path = lookup(var.acr_tasks[each.key].encoded_step, "context_path", null)
  #      secret_values = lookup(var.acr_tasks[each.key].encoded_step, "secret_values", null)
  #      value_content = lookup(var.acr_tasks[each.key].encoded_step, "value_content", null)
  #      values = lookup(var.acr_tasks[each.key].encoded_step, "values", null)
  #    }
  #  }


  #  dynamic "file_step" {
  #    for_each = lookup(var.acr_tasks[each.key], "file_step",  {}) != {} ? [1] : []
  #    content {
  #      task_file_path = lookup(var.acr_tasks[each.key].file_step, "task_file_path",  {})
  #      context_access_token = lookup(var.acr_tasks[each.key].file_step, "context_access_token", null)
  #      context_path = lookup(var.acr_tasks[each.key].file_step, "context_path", null)
  #      secret_values = lookup(var.acr_tasks[each.key].file_step, "secret_values", null)
  #      value_file_path = lookup(var.acr_tasks[each.key].file_step, "value_file_path", null)
  #      values = lookup(var.acr_tasks[each.key].file_step, "values", null)
  #    }
  #  }

  dynamic "platform" {
    for_each = lookup(var.acr_tasks[each.key], "platform", {}) != {} ? [1] : []
    content {
      os           = lookup(var.acr_tasks[each.key].platform, "os", null)
      architecture = lookup(var.acr_tasks[each.key].platform, "architecture", null)
      variant      = lookup(var.acr_tasks[each.key].platform, "variant", null)
    }
  }

  dynamic "registry_credential" {
    for_each = lookup(var.acr_tasks[each.key], "registry_credential", {}) != {} ? [1] : []
    content {

      dynamic "source" {
        for_each = lookup(var.acr_tasks[each.key].registry_credential, "source", {}) != {} ? [1] : []
        content {
          login_mode = lookup(var.acr_tasks[each.key].custom.registry_credential.source, "login_mode", null)
        }
      }

      dynamic "custom" {
        for_each = lookup(var.acr_tasks[each.key].registry_credential, "custom", {}) != {} ? [1] : []
        content {
          login_server = lookup(var.acr_tasks[each.key].custom.registry_credential.custom, "login_server", null)
          identity     = lookup(var.acr_tasks[each.key].custom.registry_credential.custom, "identity", null)
          username     = lookup(var.acr_tasks[each.key].custom.registry_credential.custom, "username", null)
          password     = lookup(var.acr_tasks[each.key].custom.registry_credential.custom, "password", null)
        }
      }
    }
  }

  dynamic "source_trigger" {
    for_each = lookup(var.acr_tasks[each.key], "source_trigger", {}) != {} ? [1] : []
    content {
      name           = lookup(var.acr_tasks[each.key].source_trigger, "name", null)
      events         = lookup(var.acr_tasks[each.key].source_trigger, "events", [])
      repository_url = lookup(var.acr_tasks[each.key].source_trigger, "repository_url", null)
      source_type    = lookup(var.acr_tasks[each.key].source_trigger, "source_type", null)
      branch         = lookup(var.acr_tasks[each.key].source_trigger, "branch", null)
      enabled        = lookup(var.acr_tasks[each.key].source_trigger, "enabled", null)

      dynamic "authentication" {
        for_each = lookup(var.acr_tasks[each.key].source_trigger, "authentication", {}) != {} ? [1] : []
        content {
          token             = lookup(var.acr_tasks[each.key].source_trigger.authentication, "token", null)
          token_type        = lookup(var.acr_tasks[each.key].source_trigger.authentication, "token_type", null)
          expire_in_seconds = lookup(var.acr_tasks[each.key].source_trigger.authentication, "expire_in_seconds", null)
          refresh_token     = lookup(var.acr_tasks[each.key].source_trigger.authentication, "refresh_token", null)
          scope             = lookup(var.acr_tasks[each.key].source_trigger.authentication, "scope", null)
        }
      }
    }
  }

  dynamic "timer_trigger" {
    for_each = lookup(var.acr_tasks[each.key], "timer_trigger", {}) != {} ? [1] : []
    content {
      name     = lookup(var.acr_tasks[each.key].timer_trigger, "name", null)
      schedule = lookup(var.acr_tasks[each.key].timer_trigger, "schedule", null)
      enabled = lookup(var.acr_tasks[each.key].timer_trigger, "enabled", null)

    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 || var.identity_type == "SystemAssigned, UserAssigned" ? [var.identity_type] : []
    content {
      type         = var.identity_type
      identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
    }
  }
}
