resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

data "shell_script" "salt_master_fingerprint" {
  depends_on = [null_resource.install_salt_master]
  lifecycle_commands {
    read = "${path.module}/bin/get-salt-master-fingerprint.sh ${var.admin_user}@${var.manager_public_ip_address}"
  }
}

data "shell_script" "salt_minion_uuid" {
  depends_on = [null_resource.install_salt_minion, null_resource.install_salt_master]
  count      = var.worker_count
  lifecycle_commands {
    read = "sh ${path.module}/bin/get-salt-minion-uuid.sh ${var.admin_user}@${var.worker_public_ip_address[count.index]}"
  }
}

data "shell_script" "salt_master_minion_uuid" {
  depends_on = [null_resource.install_salt_minion, null_resource.install_salt_master]
  lifecycle_commands {
    read = "sh ${path.module}/bin/get-salt-minion-uuid.sh ${var.admin_user}@${var.manager_public_ip_address}"
  }
}

locals {
  master_finger = data.shell_script.salt_master_fingerprint.output["fingerprint"]
  minion_uuid = concat(
    data.shell_script.salt_minion_uuid[*].output["uuid"],
  data.shell_script.salt_master_minion_uuid.output["uuid"] ? [data.shell_script.salt_master_minion_uuid.output["uuid"]] : [])
}

resource "null_resource" "install_salt_master" {
  depends_on = [
    null_resource.dependency_getter,
  ]

  triggers = {
    dependencies = null_resource.dependency_getter.id
  }

  connection {
    host        = var.manager_public_ip_address
    user        = "root"
    port        = var.ssh_port
    private_key = var.ssh_priv_key
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh",
      "sudo sh /tmp/install_salt.sh -P -M -x python3",
      "rm /tmp/install_salt.sh",
      "sudo mkdir -p /srv/salt /srv/pillar /etc/salt/autosign_grains"
    ]
  }

}

resource "null_resource" "install_salt_minion" {
  count = var.worker_count
  depends_on = [
    null_resource.dependency_getter,
  ]

  triggers = {
    dependencies = null_resource.dependency_getter.id
  }

  connection {
    host        = var.worker_public_ip_address[count.index]
    user        = var.admin_user
    port        = var.ssh_port
    private_key = var.ssh_priv_key
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://bootstrap.saltstack.com -o /tmp/install_salt.sh",
      "sudo sh /tmp/install_salt.sh -P -x python3",
      "rm /tmp/install_salt.sh"
    ]
  }

}

resource "null_resource" "configure_salt_master" {
  depends_on = [null_resource.install_salt_minion, null_resource.install_salt_master, null_resource.configure_salt_minion, null_resource.configure_salt_master_minion]

  triggers = {
    install_salt_master = null_resource.install_salt_master.id
    install_salt_minion = join(",", null_resource.install_salt_minion[*].id)
  }

  connection {
    host        = var.manager_public_ip_address
    user        = "root"
    port        = var.ssh_port
    private_key = var.ssh_priv_key
  }

  provisioner "file" {
    destination = "/etc/salt/master"
    content = yamlencode({
      "interface" : var.manager_private_ip_address,
      "file_roots" : {
        "base" : [
          "/srv/salt"
        ]
      },
      "pillar_roots" : {
        "base" : [
          "/srv/pillar"
        ]
      }
      "autosign_grains_dir" : "/etc/salt/autosign_grains",
      "publisher_acl" : {
        (var.admin_user) : [
          ".*"
        ]
      }
    })
  }

  provisioner "file" {
    destination = "/etc/salt/autosign_grains/uuid"
    content     = join("\n", local.minion_uuid)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-master"
    ]
  }
}

resource "null_resource" "configure_salt_master_minion" {
  depends_on = [null_resource.install_salt_master]
  triggers = {
    install_salt_master = null_resource.install_salt_master.id
    install_salt_minion = join(",", null_resource.install_salt_minion[*].id)
  }

  connection {
    host        = var.manager_public_ip_address
    user        = "root"
    port        = var.ssh_port
    private_key = var.ssh_priv_key
  }

  provisioner "file" {
    destination = "/etc/salt/minion"
    content = yamlencode({
      "master" : var.manager_private_ip_address,
      "master_finger" : local.master_finger,
      "grains" : {
        "roles" : [
          "infra",
          "master"
        ]
      },
      "autosign_grains" : [
        "uuid"
      ]
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "configure_salt_minion" {
  count      = var.worker_count
  depends_on = [null_resource.install_salt_minion]
  triggers = {
    install_salt_master = null_resource.install_salt_master.id
    install_salt_minion = join(",", null_resource.install_salt_minion[*].id)
  }

  connection {
    host        = var.worker_public_ip_address[count.index]
    user        = "root"
    port        = var.ssh_port
    private_key = var.ssh_priv_key
  }

  provisioner "file" {
    destination = "/etc/salt/minion"
    content = yamlencode({
      "master" : var.manager_private_ip_address,
      "master_finger" : local.master_finger,
      "grains" : {
        "roles" : [
          "worker"
        ]
      },
      "autosign_grains" : [
        "uuid"
      ]
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart salt-minion"
    ]
  }
}

# resource "null_resource" "accept_minion_keys" {
#   depends_on = [
#     null_resource.configure_salt_master,
#     null_resource.configure_salt_master_minion,
#     null_resource.configure_salt_minion
#   ]
#   connection {
#     host        = var.manager_public_ip_address
#     user        = var.admin_user
#     port        = var.ssh_port
#     private_key = var.ssh_priv_key
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo salt-key -Ay"
#     ]
#   }
# }

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
    # null_resource.accept_minion_keys,
    null_resource.install_salt_master,
    null_resource.install_salt_minion,
    null_resource.configure_salt_master,
    null_resource.configure_salt_master_minion,
    null_resource.configure_salt_minion,
  ]
}