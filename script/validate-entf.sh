#!/bin/bash

# Check if a filename is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <frontend-file-path>"
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

echo "Validating frontend file: $file_path"

# Initialize error flag and error message
has_error=0
has_warning=0
error_message=""
warning_message=""

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
if ! grep -q "^# ENTF-[0-9]\{3\}-[0-9]\{4\}:" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing or invalid main title. Should be in format '# ENTF-XXX-XXXX: 프론트엔드 개발 기능 제목'\n"
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

# Check for component structure
if ! grep -q "컴포넌트 구조:" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing component structure section\n"
fi

# Check for component models
if ! grep -q "^Component$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing Component definition\n"
fi

if ! grep -q "^Props Interface$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing Props Interface definition\n"
fi

if ! grep -q "^State Interface$" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing State Interface definition\n"
fi

# Check for API interfaces
if ! grep -q "^API 인터페이스:" "$file_path"; then
    has_error=1
    error_message="${error_message}Error: Missing API interface section\n"
else
    # Check if Function / Parameters format is defined
    if ! grep -q "^Function / Parameters / Return Type / Description$" "$file_path"; then
        has_error=1
        error_message="${error_message}Error: API interface format not properly defined\n"
    fi
fi

# Check for necessary sub-sections in review
check_subsection() {
    local section="$1"
    local file="$2"
    
    if ! grep -q "^### $section" "$file"; then
        has_error=1
        error_message="${error_message}Error: Missing required review sub-section '### $section'\n"
    fi
}

check_subsection "사용자 경험" "$file_path"
check_subsection "성능" "$file_path"
check_subsection "의존성" "$file_path"
check_subsection "트러블슈팅" "$file_path"

# Check for dependencies
if grep -q "^\".*\".*:" "$file_path"; then
    # Dependencies defined correctly
    :
elif grep -q "^\"의존성" "$file_path"; then
    # Dependencies section exists but might be in the wrong format
    has_warning=1
    warning_message="${warning_message}Warning: Dependencies section exists but might not be in the correct format. Use the format \"dependency\": \"version\"\n"
else
    # No dependencies defined
    has_warning=1
    warning_message="${warning_message}Warning: No dependencies defined. If your component has dependencies, please list them\n"
fi

# Output validation results
if [ $has_warning -eq 1 ]; then
    echo -e "${warning_message}"
fi

if [ $has_error -eq 1 ]; then
    echo -e "${error_message}"
    echo "Validation failed for $file_path"
    exit 1
else
    if [ $has_warning -eq 1 ]; then
        echo "Validation passed with warnings for $file_path"
    else
        echo "Validation passed for $file_path"
    fi
    exit 0
fi