#!/bin/bash

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

echo "Fetching plan ID for run: $RUN_ID"

# Get the plan ID from the run
PLAN_ID=$(curl \
    --silent \
    --header "Authorization: Bearer $TFE_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    "$API_BASE/runs/$RUN_ID" | \
    jq -r '.data.relationships.plan.data.id')

if [ "$PLAN_ID" = "null" ] || [ -z "$PLAN_ID" ]; then
    echo "Error: Could not retrieve plan ID for run $RUN_ID"
    echo "Check that the run ID is correct and the token has proper permissions"
    exit 1
fi

echo "Found plan ID: $PLAN_ID"
echo "Fetching JSON execution plan..."

# Get the JSON execution plan and format it
OUTPUT_FILE="${PLAN_ID}.json"

curl \
    --silent \
    --header "Authorization: Bearer $TFE_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --location \
    "$API_BASE/plans/$PLAN_ID/json-output" | \
    jq '.' > "$OUTPUT_FILE"

# Check if the file was created and has content
if [ -s "$OUTPUT_FILE" ]; then
    echo "Success! JSON plan saved to: $OUTPUT_FILE"
    echo "File size: $(echo "scale=2; $(wc -c < "$OUTPUT_FILE") / 1024" | bc) KB"

    # Pretty print a summary
    echo ""
    echo "Plan Summary:"
    echo "============="
    jq -r '.terraform_version // "Unknown"' "$OUTPUT_FILE" | sed 's/^/Terraform Version: /'
    jq -r '.resource_changes | length' "$OUTPUT_FILE" | sed 's/^/Resource Changes: /'
    jq -r '.configuration.root_module.module_calls | keys | length' "$OUTPUT_FILE" | sed 's/^/Module Calls: /'

    echo ""
    echo "To view the full JSON:"
    echo "jq . $OUTPUT_FILE"
else
    echo "Error: Failed to download JSON plan or file is empty"
    echo "Check your token permissions and plan ID"
    rm -f "$OUTPUT_FILE"
    exit 1
fi