#!/bin/bash

# Check if a filename is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backend-file-path>"
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
mkdir -p documents/api
mkdir -p documents/function

# Extract information from the file
full_title=$(grep -m 1 "^# " "$file_path" | sed 's/^# //')
title_after_colon=$(echo "$full_title" | sed 's/^.*: *//')
summary=$(sed -n '/^## 요약/,/^---/p' "$file_path" | grep -v "^## 요약" | grep -v "^---" | sed '/^$/d')

# Extract entity, request and response objects more simply
entity_content=$(sed -n '/^Entity$/,/^```$/p' "$file_path" | sed '1d;$d')
request_content=$(sed -n '/^Request Object$/,/^```$/p' "$file_path" | sed '1d;$d')
response_content=$(sed -n '/^Response Object$/,/^```$/p' "$file_path" | sed '1d;$d')

# Extract API error information
api_errors=$(sed -n '/^API 오류 반환 :/,/^---/p' "$file_path" | grep -v "^API 오류 반환 :" | grep -v "^---" | sed '/^$/d')

# Extract dependencies
dependencies=$(grep "^impl " "$file_path" | sed 's/^impl /- /')

# Extract API endpoints
api_endpoints_block=$(sed -n '/^API 엔드포인트 설계 :/,/^API 오류 반환 :/p' "$file_path")
api_lines=$(echo "$api_endpoints_block" | grep -E "^(POST|GET|PUT|DELETE|PATCH)")

# Process each API endpoint
api_count=1
while IFS= read -r api_line; do
    if [ -n "$api_line" ]; then
        # Parse API line
        http_method=$(echo "$api_line" | awk '{print $1}')
        path=$(echo "$api_line" | awk '{print $3}' | tr -d '"\\')
        path_params=$(echo "$api_line" | awk '{print $5}')
        requires_auth=$(echo "$api_line" | awk '{print $7}')
        req_obj=$(echo "$api_line" | awk '{print $9}')
        resp_obj=$(echo "$api_line" | awk '{print $11}')
        
        # Clean path for filename
        clean_path=$(echo "$path" | tr '/' '-' | sed 's/^-//')
        
        # Create API documentation for this endpoint
        api_doc_file="documents/api/${http_method}-${clean_path}.md"
        
        cat > "$api_doc_file" << EOT
# ${http_method} ${path}

## Overview
${summary}

## API Endpoint Details

- **Method:** ${http_method}
- **Path:** ${path}
- **Path Parameters:** ${path_params}
- **Authentication Required:** ${requires_auth}
- **Request Object:** ${req_obj}
- **Response Object:** ${resp_obj}

## Request Model
\`\`\`java
${request_content}
\`\`\`

## Response Model
\`\`\`java
${response_content}
\`\`\`

## Error Responses
${api_errors}

## Dependencies
${dependencies}
EOT
        
        echo "Generated API documentation: $api_doc_file"
        ((api_count++))
    fi
done <<< "$api_lines"

# Create function documentation
safe_title=$(echo "$title_after_colon" | tr ' ' '_' | tr -d '[:punct:]' | tr -d '[:cntrl:]')
func_doc_file="documents/function/${safe_title}.md"

# Generate function signatures with proper line breaks
{
    echo "# ${title_after_colon}"
    echo
    echo "## Overview"
    echo "${summary}"
    echo
    echo "## Data Models"
    echo
    echo "### Entity"
    echo "\`\`\`java"
    echo "${entity_content}"
    echo "\`\`\`"
    echo
    echo "## Implementations"
    echo
    echo "### Request Processing"
    echo "The following functions handle request processing for the API endpoints:"
    echo
    echo "\`\`\`kotlin"
    echo "// Auto-generated function signatures based on request objects"

    # Process each API for function signatures
    while IFS= read -r api_line; do
        if [ -n "$api_line" ]; then
            http_method=$(echo "$api_line" | awk '{print $1}')
            path=$(echo "$api_line" | awk '{print $3}' | tr -d '"\\')
            req_obj=$(echo "$api_line" | awk '{print $9}')
            resp_obj=$(echo "$api_line" | awk '{print $11}')

            clean_path=$(echo "$path" | sed 's/^\/api\///' | sed 's/\//_/g')
            lowercase_method=$(echo "$http_method" | tr '[:upper:]' '[:lower:]')
            func_name="${lowercase_method}_${clean_path}"

            if [ "$req_obj" != "None" ] && [ "$resp_obj" != "None" ]; then
                echo "fun ${func_name}(request: ${req_obj}): ${resp_obj}"
            elif [ "$req_obj" == "None" ] && [ "$resp_obj" != "None" ]; then
                echo "fun ${func_name}(): ${resp_obj}"
            elif [ "$req_obj" != "None" ] && [ "$resp_obj" == "None" ]; then
                echo "fun ${func_name}(request: ${req_obj}): void"
            else
                echo "fun ${func_name}(): void"
            fi
        fi
    done <<< "$api_lines"

    echo "\`\`\`"
    echo
    echo "## Error Handling"
    echo
    echo "${api_errors}"
    echo
    echo "## Dependencies"
    echo "${dependencies}"
} > "$func_doc_file"

echo "Function Documentation: $func_doc_file"
echo "Total API endpoints processed: $((api_count-1))"