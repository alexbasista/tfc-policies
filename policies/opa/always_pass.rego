package terraform.policies.always_pass

import input.plan as plan

# Set default to empty array so query never returns undefined
default deny = []