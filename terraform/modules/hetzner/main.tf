provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "admin_key" {
  name       = "${var.deployment}-admin-key"
  public_key = var.ssh_pub_key
}

resource "hcloud_network" "private" {
  name     = "${var.deployment}-private"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "nodes" {
  network_id   = hcloud_network.private.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.1.0.0/16"
}

resource "hcloud_server" "manager" {
  name        = "${var.deployment}-manager"
  image       = var.manager_base_image
  server_type = var.manager_machine_type
  location    = var.hcloud_region
  user_data   = var.manager_cloud_init
  ssh_keys    = [hcloud_ssh_key.admin_key.id]
}

resource "hcloud_server" "worker" {
  name        = "${var.deployment}-worker-${count.index}"
  image       = var.worker_base_image
  server_type = var.worker_machine_type
  location    = var.hcloud_region
  user_data   = var.worker_cloud_init
  ssh_keys    = [hcloud_ssh_key.admin_key.id]
  count       = var.worker_count

}

resource "hcloud_server_network" "worker" {
  server_id  = hcloud_server.worker[count.index].id
  network_id = hcloud_network.private.id
  ip         = "10.1.1.${count.index + 1}"
  count      = var.worker_count
}

resource "hcloud_server_network" "manager" {
  server_id  = hcloud_server.manager.id
  network_id = hcloud_network.private.id
  ip         = "10.1.0.1"
}

# resource "null_resource" "wait_for_manager" {
#   triggers = {
#     manager_server_id = hcloud_server.manager.id
#   }

#   connection {
#     host        = hcloud_server.manager.ipv4_address
#     user        = var.admin_user
#     port        = var.ssh_port
#     private_key = local.ssh_priv_key
#     timeout     = "10m"
#   }

#   provisioner "remote-exec" {
#     script = "${path.module}/bin/wait-for-cloud-init"
#   }
# }

# resource "null_resource" "wait_for_worker" {
#   count = var.worker_count

#   triggers = {
#     worker_server_id = hcloud_server.worker[count.index].id
#   }

#   connection {
#     host        = hcloud_server.worker[count.index].ipv4_address
#     user        = var.admin_user
#     port        = var.ssh_port
#     private_key = local.ssh_priv_key
#     timeout     = "10m"
#   }

#   provisioner "remote-exec" {
#     script = "${path.module}/bin/wait-for-cloud-init"
#   }
# }

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
    hcloud_server.manager,
    hcloud_server.worker,
    hcloud_server_network.manager,
    hcloud_server_network.worker,
  ]
}