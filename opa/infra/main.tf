data "tfe_slug" "opa_global" {
  source_path = "../policy-sets/global"
}

resource "tfe_policy_set" "test" {
  name          = "opa-api-global"
  organization  = "abasista-tfc"
  kind          = "opa"
  global        = true 

  // reference the tfe_slug data source.
  slug = data.tfe_slug.opa_global
}