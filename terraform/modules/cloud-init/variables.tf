variable "admin_user" {
  type        = string
  default     = "admin"
  description = "Name of the created admin user."
}

variable "ssh_pub_key" {
  type        = string
  description = "Public key to install on created servers"
}