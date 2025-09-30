policy "always_pass" {
  source            = "../../policies/always_pass.sentinel"
  enforcement_level = "soft-mandatory"
}

policy "always_fail" {
  source            = "../../policies/always_fail.sentinel"
  enforcement_level = "advisory"
}