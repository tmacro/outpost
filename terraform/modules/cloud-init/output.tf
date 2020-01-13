output "cloud-init" {
  value = data.template_cloudinit_config.config.rendered
  sensitive = true
}