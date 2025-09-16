package terraform.policies.always_pass

import input.plan as plan

# Look for something that will never exist - this ensures deny rule exists but never matches
deny[msg] {
    plan.resource_changes[_].type == "resource_that_will_never_exist_in_any_plan"
    msg := "This should never trigger"
}