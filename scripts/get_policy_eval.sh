#!/bin/bash

# Script to get policy violation details from TFC/TFE
#
# Usage: ./get_policy_eval.sh <run-id>
#
# Arguments:
#   run-id        The ID of the Terraform run to fetch policy evaluation details for.
#
# Environment:
#   TFE_TOKEN     Required. API token for Terraform Cloud/Enterprise.


set -euo pipefail

TFE_TOKEN="${TFE_TOKEN:-}"
RUN_ID="${1:-}"

if [[ -z "$TFE_TOKEN" ]]; then
    echo "❌ Error: TFE_TOKEN environment variable is not set."
    echo "Usage: $0 <run-id>"
    exit 1
fi

if [[ -z "$RUN_ID" ]]; then
    echo "❌ Error: Missing run ID argument."
    echo "Usage: $0 <run-id>"
    exit 1
fi

API_BASE="https://app.terraform.io/api/v2"
HEADERS="Authorization: Bearer $TFE_TOKEN"

# Get run details and extract task stage ID
RUN_DETAILS=$(curl -s -H "$HEADERS" "$API_BASE/runs/$RUN_ID")
TASK_STAGE_ID=$(echo "$RUN_DETAILS" | jq -r '.data.relationships."task-stages".data[0].id')

echo "🔍 Policy Results for Run: $RUN_ID"
echo "=================================="
echo "Task Stage ID: $TASK_STAGE_ID"
echo

# Get policy evaluations from the task stage
POLICY_EVALUATIONS=$(curl -s -H "$HEADERS" "$API_BASE/task-stages/$TASK_STAGE_ID/policy-evaluations")

# Print policy evaluation summary
echo "📋 Policy Evaluations:"
echo "$POLICY_EVALUATIONS" | jq -r '.data[] | "  - \(.id) (\(.attributes."policy-kind")) - Status: \(.attributes.status) - Results: \(.attributes."result-count" | to_entries | map("\(.key): \(.value)") | join(", "))"'

echo

# Get policy-set-outcomes for each evaluation
echo "📋 Policy Set Outcomes:"
PSOUT_IDS=$(echo "$POLICY_EVALUATIONS" | jq -r '.data[].relationships."policy-set-outcomes".data[].id')

for psout_id in $PSOUT_IDS; do
    echo
    echo "🔍 Policy Set Outcome: $psout_id"
    echo "--------------------------------"
    
    PSOUT_DETAILS=$(curl -s -H "$HEADERS" "$API_BASE/policy-set-outcomes/$psout_id")
    
    # Get the policy kind from the related policy evaluation
    POLICY_EVAL_ID=$(echo "$PSOUT_DETAILS" | jq -r '.data.relationships."policy-evaluation".data.id')
    POLICY_KIND=$(echo "$POLICY_EVALUATIONS" | jq -r ".data[] | select(.id == \"$POLICY_EVAL_ID\") | .attributes.\"policy-kind\"")
    
    echo "Policy Kind: $POLICY_KIND"
    
    # Extract outcomes based on policy kind
    if [[ "$POLICY_KIND" == "sentinel" ]]; then
        # Sentinel format: outcomes[].output[].print
        echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[] | "Policy: \(.policy_name)\nStatus: \(.status)\nOutput: \(.output[].print // "No print output")"'
    elif [[ "$POLICY_KIND" == "opa" ]]; then
        # OPA format: outcomes[].output[] (direct message)
        echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[] | "Policy: \(.policy_name // "Unknown")\nStatus: \(.status)\nOutput: \(.output[] // "No output")"'
    else
        echo "Unknown policy kind: $POLICY_KIND"
        echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[]'
    fi
done