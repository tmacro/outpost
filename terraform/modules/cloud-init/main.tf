data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = <<-EOT
        #cloud-config
        ssh_authorized_keys:
          - ${var.ssh_pub_key}
        users:
          - name: ${var.admin_user}
            groups: docker
            lock_passwd: true # disable password login
            ssh_authorized_keys:
              - ${var.ssh_pub_key}
            sudo: ALL=(ALL) NOPASSWD:ALL
            shell: /usr/bin/fish
        ntp:
          enabled: true
        packages:
          - sudo
          - fish
    EOT
  }
}