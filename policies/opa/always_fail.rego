# OPA Policy: Always Fail  
# File: always_fail.rego
package terraform.policies.always_fail

import input.plan as plan

deny[msg] {
    true
    msg := "This is a test policy that always fails - policy evaluation is working correctly!"
}