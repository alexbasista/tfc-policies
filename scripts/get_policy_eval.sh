#!/bin/bash

# Script to get policy violation details from TFC/TFE
#
# API path: Run → Task Stage → Policy Evaluations → Policy Set Outcomes
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
POLICY_EVAL_COUNT=$(echo "$POLICY_EVALUATIONS" | jq '.data | length')
echo "📊 Found $POLICY_EVAL_COUNT policy evaluation(s)"

# Print policy evaluation summary
echo "📋 Policy Evaluations:"
echo "$POLICY_EVALUATIONS" | jq -r '.data[] | "  - \(.id) (\(.attributes."policy-kind")) - Status: \(.attributes.status) - Results: \(.attributes."result-count" | to_entries | map("\(.key): \(.value)") | join(", "))"'

echo

# Process each policy evaluation and its policy set outcomes

echo "$POLICY_EVALUATIONS" | jq -r '.data[] | @base64' | while IFS= read -r evaluation; do
    eval_data=$(echo "$evaluation" | base64 --decode)
    eval_id=$(echo "$eval_data" | jq -r '.id')
    eval_kind=$(echo "$eval_data" | jq -r '.attributes."policy-kind"')
    eval_status=$(echo "$eval_data" | jq -r '.attributes.status')
    
    echo
    echo "🎯 Policy Evaluation: $eval_id ($eval_kind) - Status: $eval_status"
    printf '=%.0s' {1..70} && echo
    
    # Get policy set outcome IDs for this specific evaluation
    PSOUT_IDS=$(echo "$eval_data" | jq -r '.relationships."policy-set-outcomes".data[].id')
    
    if [[ -z "$PSOUT_IDS" ]]; then
        echo "  No policy set outcomes found for this evaluation"
        continue
    fi
    
    for psout_id in $PSOUT_IDS; do
        echo
        echo "🔍 Policy Set Outcome: $psout_id"
        echo "--------------------------------"
        
        PSOUT_DETAILS=$(curl -s -H "$HEADERS" "$API_BASE/policy-set-outcomes/$psout_id")
        
        echo "Policy Kind: $eval_kind"
        
        # Extract outcomes based on policy kind
        if [[ "$eval_kind" == "sentinel" ]]; then
            # Sentinel format: outcomes[].output[].print
            echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[] | "Policy: \(.policy_name)\nStatus: \(.status)\nOutput: \(.output[].print // "No print output")"'
        elif [[ "$eval_kind" == "opa" ]]; then
            # OPA format: outcomes[].output[] (direct message)
            echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[] | "Policy: \(.policy_name // "Unknown")\nStatus: \(.status)\nOutput: \(.output[] // "No output")"'
        else
            echo "Unknown policy kind: $eval_kind"
            echo "$PSOUT_DETAILS" | jq -r '.data.attributes.outcomes[]'
        fi
    done
done