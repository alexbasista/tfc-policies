policy "enforce-random-pet-length" {
  source           = "../../policies/enforce_random_pet_length.sentinel"
  enforcement_mode = "soft-mandatory"
  description      = "Enforce length attribute of random_pet resources."
}