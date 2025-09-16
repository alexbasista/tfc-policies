# policy "always_pass" {
#   query             = "data.terraform.policies.always_pass.deny"
#   enforcement_level = "mandatory"
#   description       = "OPA policy to always pass."
# }

# policy "always_fail" {
#   query             = "data.terraform.policies.always_fail.deny"
#   enforcement_level = "advisory"
#   description       = "OPA policy to always fail."
# }

policy "restrict_pet_length" {
  query = "data.terraform.policies.random_pet_length.deny"
  enforcement_level = "mandatory"
  description = "testing"
}