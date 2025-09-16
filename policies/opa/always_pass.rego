package terraform.policies.always_pass

import input.plan as plan

deny[msg] {
    plan.resource_changes[_].type == "nonexistent_resource_type"
    msg := "This condition will never be true"
}
