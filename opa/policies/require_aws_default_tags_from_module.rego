# OPA Policy: Tagging Module Required
# This policy ensures that:
# 1. The required module exists in the configuration
# 2. The module is sourced from an approved registry
# 3. The AWS provider uses default_tags that reference the module output
# This enforces consistent tagging across all AWS resources.

package terraform.policies.tagging

import input.plan as plan

# Policy parameters (update these values accordingly)
required_module_name := "tagging_module_call"
required_module_output := "tagging_module_outputs"
required_module_source := "./modules/tagging"

# Check if required tagging module exists
tagging_module_exists {
    plan.configuration.root_module.module_calls[required_module_name]
}

# Check if tagging module has correct source
tagging_module_has_correct_source {
    module := plan.configuration.root_module.module_calls[required_module_name]
    module.source == required_module_source
}

# Check if AWS provider has default_tags configured with tagging module reference
aws_provider_has_tagging {
    provider := plan.configuration.provider_config.aws
    provider.expressions.default_tags[_].tags.references[_] == sprintf("module.%s.%s", [required_module_name, required_module_output])
}

# Collect all violations
violations[msg] {
    not tagging_module_exists
    msg := sprintf("Missing required '%s' module in configuration", [required_module_name])
}

violations[msg] {
    tagging_module_exists
    not tagging_module_has_correct_source
    actual_source := plan.configuration.root_module.module_calls[required_module_name].source
    msg := sprintf("Module '%s' must be sourced from: %s (currently using: %s)", [required_module_name, required_module_source, actual_source])
}

violations[msg] {
    not aws_provider_has_tagging
    expected_reference := sprintf("module.%s.%s", [required_module_name, required_module_output])
    msg := sprintf("AWS provider must use 'default_tags' with 'tags = %s'", [expected_reference])
}

# Main deny rule - policy fails if there are any violations
deny[msg] {
    msg := violations[_]
}