# OPA Policy: Always Pass
# File: always_pass.rego
package terraform.policies.always_pass

import input.plan as plan

deny[msg] {
    false
    msg := "This will never execute."
}
