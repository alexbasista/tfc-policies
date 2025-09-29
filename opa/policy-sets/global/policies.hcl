policy "always_pass" {
  query             = "data.terraform.policies.always_pass.deny"
  description       = "Returns `true` to always pass."
  enforcement_level = "mandatory"
}

policy "always_fail" {
  query             = "data.terraform.policies.always_fail.deny"
  description       = "Returns `false` to always fail."
  enforcement_level = "advisory"
}

policy "restrict_pet_length" {
  query             = "data.terraform.policies.random_pet_length.deny"
  description       = "Enforce the max of `length` attribute on `random_pet` resource."
  enforcement_level = "mandatory"
}

policy "require_aws_default_tags_from_module" {
  query             = "data.terraform.policies.aws_default_tagging.deny"
  description       = "Require AWS provider block has default_tags stanza with tagging module reference."
  enforcement_level = "advisory"
}