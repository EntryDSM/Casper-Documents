#!/bin/bash

# Check if a filename is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <frontend-file-path>"
    exit 1
fi

# Get the file path from arguments
file_path="$1"
file_name=$(basename "$file_path")
file_id=${file_name%.*}

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "Error: File not found: $file_path"
    exit 1
fi

echo "Processing file: $file_path"

# Create directories if they don't exist
mkdir -p documents/component
mkdir -p documents/function

# Extract information from the file
full_title=$(grep -m 1 "^# " "$file_path" | sed 's/^# //')
title_after_colon=$(echo "$full_title" | sed 's/^.*: *//')
summary=$(sed -n '/^## 요약/,/^---/p' "$file_path" | grep -v "^## 요약" | grep -v "^---" | sed '/^$/d')

# Extract component, props and state interfaces
component_content=$(sed -n '/^Component$/,/^```$/p' "$file_path" | sed '1d;$d')
props_content=$(sed -n '/^Props Interface$/,/^```$/p' "$file_path" | sed '1d;$d')
state_content=$(sed -n '/^State Interface$/,/^```$/p' "$file_path" | sed '1d;$d')

# Extract API interfaces
api_block=$(sed -n '/^API 인터페이스:/,/^에러 처리:/p' "$file_path")
api_lines=$(echo "$api_block" | grep -E "^Function")

# Extract dependencies
dependencies=$(sed -n '/^"의존성/,/^```$/p' "$file_path" | grep "^\"" | sed 's/^/- /')

# Create component documentation
safe_title=$(echo "$title_after_colon" | tr ' ' '_' | tr -d '[:punct:]' | tr -d '[:cntrl:]')
component_doc_file="documents/component/${safe_title}_Component.md"

{
    echo "# ${title_after_colon} Component"
    echo
    echo "## Overview"
    echo "${summary}"
    echo
    echo "## Component Structure"
    echo
    echo "### Component"
    echo "\`\`\`tsx"
    echo "${component_content}"
    echo "\`\`\`"
    echo
    echo "### Props Interface"
    echo "\`\`\`typescript"
    echo "${props_content}"
    echo "\`\`\`"
    echo
    echo "### State Interface"
    echo "\`\`\`typescript"
    echo "${state_content}"
    echo "\`\`\`"
    echo
    echo "## Dependencies"
    echo "${dependencies}"
} > "$component_doc_file"

echo "Generated Component Documentation: $component_doc_file"

# Create function documentation
func_doc_file="documents/function/${safe_title}_Functions.md"

{
    echo "# ${title_after_colon} Functions"
    echo
    echo "## Overview"
    echo "${summary}"
    echo
    echo "## API Functions"
    echo

    # Extract API interface details
    echo "| Function | Parameters | Return Type | Description |"
    echo "|----------|------------|-------------|-------------|"

    # Process each API line
    while IFS= read -r api_line; do
        if [[ $api_line == Function* ]]; then
            # Skip the header line
            continue
        fi

        if [ -n "$api_line" ]; then
            func_name=$(echo "$api_line" | awk -F ' / ' '{print $1}')
            params=$(echo "$api_line" | awk -F ' / ' '{print $2}')
            return_type=$(echo "$api_line" | awk -F ' / ' '{print $3}')
            description=$(echo "$api_line" | awk -F ' / ' '{print $4}')

            echo "| $func_name | $params | $return_type | $description |"
        fi
    done <<< "$(echo "$api_block" | grep -v "^API 인터페이스:" | grep -v "^에러 처리:" | grep -v "^형식:" | grep -v "^\`\`\`")"

    echo
    echo "## Function Implementations"
    echo
    echo "\`\`\`typescript"
    echo "// Auto-generated function signatures based on API interface"

    # Process each API for function signatures
    while IFS= read -r api_line; do
        if [[ $api_line == Function* ]]; then
            # Skip the header line
            continue
        fi

        if [ -n "$api_line" ]; then
            func_name=$(echo "$api_line" | awk -F ' / ' '{print $1}')
            params=$(echo "$api_line" | awk -F ' / ' '{print $2}')
            return_type=$(echo "$api_line" | awk -F ' / ' '{print $3}')

            # Convert parameters to TypeScript function parameters
            if [ "$params" != "None" ] && [ -n "$params" ]; then
                formatted_params=$(echo "$params" | sed -E 's/([^,]+): ([^,]+)(, )?/\1: \2, /g' | sed 's/, $//')
                echo "async function ${func_name}(${formatted_params}): Promise<${return_type}> {"
            else
                echo "async function ${func_name}(): Promise<${return_type}> {"
            fi
            echo "  // Implementation"
            echo "  return {} as ${return_type};"
            echo "}"
            echo
        fi
    done <<< "$(echo "$api_block" | grep -v "^API 인터페이스:" | grep -v "^에러 처리:" | grep -v "^형식:" | grep -v "^\`\`\`")"

    echo "\`\`\`"
    echo
    echo "## Dependencies"
    echo "${dependencies}"
} > "$func_doc_file"

echo "Generated Function Documentation: $func_doc_file"