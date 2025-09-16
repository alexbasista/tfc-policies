policy "always_pass" {
   query             = "data.terraform.policies.always_pass.allow"
   enforcement_level = "mandatory"
   description       = "OPA policy to always pass."
}

policy "always_fail" {
   query             = "data.terraform.policies.always_fail.allow"
   enforcement_level = "advisory"
   description       = "OPA policy to always fail."
}
