# Policy 1: Always Pass (OPA v1.0+ syntax)
# File: always_pass.rego
package terraform.policies.always_pass

import input.plan as plan

# New v1.0+ syntax with "contains" and "if" keywords
deny contains msg if {
    plan.terraform_version == "99.99.99"
    msg := "This should never trigger - impossible Terraform version"
}