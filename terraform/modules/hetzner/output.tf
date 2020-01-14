
output "worker_public_ips" {
  value = "${hcloud_server.worker[*].ipv4_address}"
}

output "manager_public_ip" {
  value = "${hcloud_server.manager.ipv4_address}"
}

output "worker_private_ips" {
  value = "${hcloud_server_network.worker[*].ip}"
}

output "manager_private_ip" {
  value = "${hcloud_server_network.manager.ip}"
}

output "manager_server_id" {
  value = "${hcloud_server.manager.id}"
}

output "worker_server_ids" {
  value = "${hcloud_server.worker[*].id}"
}

output "depended_on" {
  value = null_resource.dependency_setter.id
}