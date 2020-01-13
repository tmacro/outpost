variable "deployment" {
  type        = string
  description = "Prefix for all created resources"
}

variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud token"
}

variable "hcloud_region" {
  type        = string
  description = "HCloud region"
}

variable "worker_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes to provision"
}

variable "ssh_pub_key" {
  type        = string
  description = "Public key to install on created servers"
}

variable "worker_base_image" {
  type        = string
  default     = "ubuntu-18.04"
  description = "Base image for workers"
}

variable "worker_machine_type" {
  type        = string
  default     = "cx41"
  description = "VM type for workers"
}

variable "worker_cloud_init" {
  type        = string
  default     = ""
  description = "cloud-init for workers"
}

variable "manager_base_image" {
  type        = string
  default     = "ubuntu-18.04"
  description = "Base image for managers"
}

variable "manager_machine_type" {
  type        = string
  default     = "cx41"
  description = "VM type for managers"
}

variable "manager_cloud_init" {
  type        = string
  default     = ""
  description = "cloud-init for managers"
}