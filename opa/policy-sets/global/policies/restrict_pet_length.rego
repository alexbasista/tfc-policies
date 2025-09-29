# OPA Policy: Restrict random_pet length
# This policy ensures that random_pet resources do not use a length greater than 3
# Supports workspace exceptions for testing/development environments
package terraform.policies.random_pet_length

import input.plan as plan
import input.run as run

# Workspace exceptions - these workspaces are allowed to use any length
workspace_exceptions := {
    "testing-workspace", 
    "experimental-env",
    "opa-test"
}

deny[msg] {
    r := plan.resource_changes[_]
    r.type == "random_pet"
    
    # Check if length exists and is greater than 3
    length := r.change.after.length
    length > 3
    
    # Skip policy for exception workspaces
    not workspace_exceptions[run.workspace.name]
    
    msg := sprintf("Resource '%s' has length %v which exceeds the maximum allowed length of 3. Workspace: %s", [r.address, length, run.workspace.name])
}