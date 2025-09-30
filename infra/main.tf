terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.70.0"
    }
  }
}

provider "tfe" {
  # Configuration options
}

# -----------------------------------------------------------------------------
# Sentinel policy set - 'global'
# -----------------------------------------------------------------------------
data "tfe_slug" "sentinel_polset_global" {
  source_path = "../sentinel"
}

resource "tfe_policy_set" "sentinel_polset_global" {
  name                = "sentinel-global"
  description         = "Sentinel policy set scoped to all workspaces in the organization (global), created via the API."
  organization        = "abasista-tfc"
  kind                = "sentinel"
  global              = true
  policies_path       = "policy-sets/global"
  agent_enabled       = true
  policy_tool_version = "0.40.0"

  slug = data.tfe_slug.sentinel_polset_global

  lifecycle {
    ignore_changes = [policies_path]
  }
}

# -----------------------------------------------------------------------------
# OPA policy set - 'global'
# -----------------------------------------------------------------------------
data "tfe_slug" "opa_polset_global" {
  source_path = "../opa"
}

resource "tfe_policy_set" "opa_polset_global" {
  name                = "opa-global"
  description         = "OPA policy set scoped to all workspaces in the organization (global), created via the API."
  organization        = "abasista-tfc"
  kind                = "opa"
  global              = true
  policies_path       = "policy-sets/global"
  agent_enabled       = true
  policy_tool_version = "0.61.0"

  slug = data.tfe_slug.opa_polset_global

  lifecycle {
    ignore_changes = [policies_path]
  }
}