policy "always_pass" {
  source            = "../policies/always_pass.sentinel"
  description       = "Sentinel policy to always pass."
  enforcement_level = "soft-mandatory"
}

policy "always_fail" {
  source            = "../policies/always_fail.sentinel"
  description       = "Sentinel policy to always fail."
  enforcement_level = "soft-mandatory"
}

policy "require_aws_default_tags_from_module" {
  source            = "../policies/require_aws_default_tags_from_module.sentinel"
  description       = "Require AWS provider block has default_tags stanza populated with a tagging module output reference."
  enforcement_level = "soft-mandatory"
}