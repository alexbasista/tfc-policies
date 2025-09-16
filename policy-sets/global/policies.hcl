policy "always_pass" {
  query             = "data.terraform.policies.always_pass.deny"
  enforcement_level = "mandatory"
  description       = "OPA policy to always pass."
}

policy "always_fail" {
  query             = "data.terraform.policies.always_fail.deny"
  enforcement_level = "advisory"
  description       = "OPA policy to always fail."
}
