# Number of worker nodes
variable "worker_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes to provision"
}

variable "manager_public_ip_address" {
  type        = string
  description = "Manager ip address"
}
variable "worker_public_ip_address" {
  type        = list(string)
  description = "Worker node ip addresses"
}

variable "manager_private_ip_address" {
  type        = string
  description = "Manager ip address"
}
variable "worker_private_ip_address" {
  type        = list(string)
  description = "Worker node ip addresses"
}


# Admin User
variable "admin_user" {
  type        = string
  default     = "admin"
  description = "Name of the created admin user."
}

variable "ssh_priv_key" {
  type        = string
  description = "Private key for server administration"
}

variable "ssh_pub_key" {
  type        = string
  description = "Public key to install on created servers"
}

variable "ssh_port" {
  type        = string
  description = "Port for ssh connections"
  default     = 22
}

variable "dependencies" {
  type = list(string)
}
