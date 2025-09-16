# OPA Policy: Restrict random_pet length
# This policy ensures that random_pet resources do not use a length greater than 3
package terraform.policies.random_pet_length

import input.plan as plan

deny[msg] {
    r := plan.resource_changes[_]
    r.type == "random_pet"
    
    # Check if length is greater than 3
    r.change.after.length > 3
    
    msg := sprintf("Resource '%s' has length %v which exceeds the maximum allowed length of 3", [r.address, r.change.after.length])
}