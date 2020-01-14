output "cloud_init" {
  value     = data.template_cloudinit_config.config.rendered
  sensitive = true
}