package terraform.policies.always_fail

import input.plan as plan

# Simple deny rule that always triggers
deny[msg] {
    msg := "This test policy always fails - evaluation working correctly!"
}