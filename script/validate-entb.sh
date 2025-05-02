#!/bin/bash

# Check if a filename is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backend-file-path>"
    exit 1
fi

# Get the file path from arguments
file_path="$1"
file_name=$(basename "$file_path")

# Check if the file exists
if [ ! -f "$file_path" ]; then
    echo "Error: File not found: $file_path"
    exit 1
fi

echo "Validating backend file: $file_path"

# Initialize error flag and error message
has_error=0
error_message=""

# Check for required sections
check_section() {
    local section="$1"
    local file="$2"
    
    if ! grep -q "^## $section" "$file"; then
        has_error=1
        error_message="${error_message}Error: Missing required section '## $section'\n"
    fi
}

# Check for main title
if ! grep -q "^# ENTB-[0-9]\{3\}-[0-9]\{4\}:" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing or invalid main title. Should be in format '# ENTB-XXX-XXXX: 백엔드 개발 기능 제목'\n"
fi

# Check for required sections
check_section "요약" "$file_path"
check_section "동기" "$file_path"
check_section "제안" "$file_path"
check_section "검토 설문" "$file_path"
check_section "대안" "$file_path"
check_section "보안 고려 사항" "$file_path"

# Check for sub-sections
if ! grep -q "### 목표" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing required sub-section '### 목표'\n"
fi

if ! grep -q "### 목표가 아닌 것" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing required sub-section '### 목표가 아닌 것'\n"
fi

if ! grep -q "### 기술 설계" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing required sub-section '### 기술 설계'\n"
fi

# Check for data models
if ! grep -q "^Entity$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing Entity data model definition\n"
fi

if ! grep -q "^Request Object$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing Request Object data model definition\n"
fi

if ! grep -q "^Response Object$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing Response Object data model definition\n"
fi

# Check for API endpoints
if ! grep -q "^API 엔드포인트 설계 :" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing API endpoint design section\n"
else
    # Check if at least one API endpoint is defined
    api_endpoints_block=$(sed -n '/^API 엔드포인트 설계 :/,/^API 오류 반환 :/p' "$file_path")
    api_lines=$(echo "$api_endpoints_block" | grep -E "^(POST|GET|PUT|DELETE|PATCH)")
    
    if [ -z "$api_lines" ]; then
        has_error=1
        error_message="${error_message}Error: No API endpoints defined. At least one endpoint should be defined\n"
    fi
fi

# Check for dependencies
if ! grep -q "^impl " "$file_path"; then
    has_error=1
    error_message="${error_message}Warning: No dependencies defined. If your service has dependencies, please list them\n"
fi

# Check for API error handling
if ! grep -q "^API 오류 반환 :" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing API error handling section\n"
fi

# Output validation results
if [ $has_error -eq 1 ]; then
    echo -e "${error_message}"
    echo "Validation failed for $file_path"
    exit 1
else
    echo "Validation passed for $file_path"
    exit 0
fi