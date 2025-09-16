package terraform.policies.always_pass

import input.plan as plan

deny[msg] {
    # Look for a terraform_version that will never exist
    plan.terraform_version == "99.99.99"
    msg := "This should never trigger - impossible Terraform version"
}
