output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}

output "salt_master_fingerprint" {
  value = local.master_finger
}

output "salt_minion_uuids" {
  value = local.minion_uuid[*]
}
