variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "bambam"
}

variable "tags" {
    description = "name of the tag to be used for all resources deployed for the creating on the vm(s)"
    type        = map(string)
    default = {
        project_stage = "development"
        }
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "East US"
}

variable "username" {
  description = "The VM admin username to be used."
  default     = "accessbankuser"
}

variable "password" {
  description = "The VM admin password to be used"
  default     = "Password123#"
}

variable "vm-number" {
  description = "The amount of VMs that will be created."
  default     = 2
}

variable "lb_sku" {
  description = "(Optional) The SKU of the Azure Load Balancer. Its accepted values are Basic and Standard."
  type        = string
  default     = "Basic"
}

variable "vm-update-number" {
  description = "The number of VMs that should be spun up when a specific one is updating the OS system."
  default     = 5
}

variable "vm-fault-number" {
  description = "The number of VMs that should be spun when a specific one is failing or having any kind of issues."
  default     = 3
  }



