data "tfe_slug" "sentinel_polset_global" {
  source_path = "../policy-sets/global"
}

resource "tfe_policy_set" "sentinel_global" {
  name          = "sentinel-global"
  organization  = "abasista-tfc"
  kind          = "sentinel"
  global        = true
  policies_path = "../policies"

  slug = data.tfe_slug.sentinel_polset_global
}