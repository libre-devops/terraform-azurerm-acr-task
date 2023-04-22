variable "acr_id" {
  description = "The ID of the ACR this tasks is being made for"
  type        = string
}

variable "acr_tasks" {
  description = "The ACR tasks block where each key is the name of the task"
  type        = any
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned to the VM."
  type        = list(string)
  default     = []
}

variable "identity_type" {
  description = "The Managed Service Identity Type of this Virtual Machine."
  type        = string
  default     = ""
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "schedule_task_run_now" {
  description = "Whether a task should be scheduled for now, defaults to true"
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
