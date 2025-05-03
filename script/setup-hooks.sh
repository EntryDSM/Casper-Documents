#!/bin/bash

# 이 스크립트는 프로젝트의 git hooks를 설정합니다.

# 스크립트가 있는 디렉토리 경로를 가져옵니다.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

echo "Casper Documents Git Hooks 설정을 시작합니다..."

# .githooks 디렉토리가 존재하는지 확인하고, 권한 설정
if [ -d "$PROJECT_ROOT/.githooks" ]; then
  chmod +x "$PROJECT_ROOT/.githooks/pre-commit"
  echo "훅 스크립트에 실행 권한을 부여했습니다."
else
  echo "오류: .githooks 디렉토리를 찾을 수 없습니다."
  exit 1
fi

# 로컬 git 설정 업데이트
git config core.hooksPath .githooks
echo "Git hooks 경로를 .githooks로 설정했습니다."

# 검증 스크립트에 실행 권한 부여
chmod +x "$PROJECT_ROOT/script/validate-entb.sh"
chmod +x "$PROJECT_ROOT/script/validate-entf.sh"
echo "검증 스크립트에 실행 권한을 부여했습니다."

echo "설정이 완료되었습니다. 이제 문서 파일을 커밋할 때마다 자동으로 유효성 검사가 실행됩니다."
