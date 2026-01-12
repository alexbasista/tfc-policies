policy "enforce_random_pet_length" {
  source            = "../../policies/enforce_random_pet_length.sentinel"
  enforcement_level = "soft-mandatory"
  description       = "Enforce length attribute of random_pet resources."
}