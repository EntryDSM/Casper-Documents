# Casper Documents

프로젝트 문서 자동화 시스템입니다. 이 시스템은 마크다운 형식의 백엔드 및 프론트엔드 문서에서 API, 컴포넌트, 함수 문서를 자동으로 생성합니다.

## 프로젝트 소개

Casper Documents는 정형화된 마크다운 문서를 파싱하여 다음과 같은 문서를 자동으로 생성합니다:

- **백엔드 명세(ENTB)**: API 문서와 함수 문서 생성
- **프론트엔드 명세(ENTF)**: 컴포넌트 문서와 함수 문서 생성

이를 통해 프로젝트 문서의 일관성을 유지하고, 개발자가 문서화에 소요하는 시간을 절약할 수 있습니다.

## 디렉토리 구조

```
.
├── .github/workflows        # GitHub Actions 워크플로우 정의
├── .githooks                # Git 훅 스크립트
├── documents                # 문서 디렉토리
│   ├── api                  # 생성된 API 문서
│   ├── backend              # 백엔드 명세 문서 (ENTB)
│   ├── component            # 생성된 컴포넌트 문서
│   ├── frontend             # 프론트엔드 명세 문서 (ENTF)
│   ├── function             # 생성된 함수 문서
│   └── templates            # 문서 템플릿
│       ├── backend          # 백엔드 문서 템플릿
│       └── frontend         # 프론트엔드 문서 템플릿
└── script                   # 스크립트 파일
    ├── parsing-entb.sh      # 백엔드 문서 파싱 스크립트
    ├── parsing-entf.sh      # 프론트엔드 문서 파싱 스크립트
    ├── validate-entb.sh     # 백엔드 문서 유효성 검사 스크립트
    ├── validate-entf.sh     # 프론트엔드 문서 유효성 검사 스크립트
    └── setup-hooks.sh       # Git 훅 설정 스크립트
```

## 설치 및 설정

### Git 훅 설정

프로젝트를 클론한 후 다음 명령을 실행하여 Git 훅을 설정합니다:

```bash
./script/setup-hooks.sh
```

이 스크립트는 문서 파일을 커밋할 때마다 자동으로 유효성 검사를 실행하도록 Git 훅을 설정합니다.

## 사용 방법

### 백엔드 문서 작성

1. `documents/backend/` 디렉토리에 `ENTB-XXX-XXXX.md` 형식의 마크다운 파일을 생성합니다.
2. 템플릿을 참고하여 백엔드 명세를 작성합니다.
3. 문서를 커밋하면 Git 훅이 자동으로 문서 유효성을 검사합니다.
4. 유효성 검사를 통과하면 GitHub Actions가 자동으로 API 문서와 함수 문서를 생성합니다.

### 프론트엔드 문서 작성

1. `documents/frontend/` 디렉토리에 `ENTF-XXX-XXXX.md` 형식의 마크다운 파일을 생성합니다.
2. 템플릿을 참고하여 프론트엔드 명세를 작성합니다.
3. 문서를 커밋하면 Git 훅이 자동으로 문서 유효성을 검사합니다.
4. 유효성 검사를 통과하면 GitHub Actions가 자동으로 컴포넌트 문서와 함수 문서를 생성합니다.

### 문서 유효성 검사

작성한 문서가 템플릿에 맞게 작성되었는지 확인하려면 다음 명령어를 사용합니다:

```bash
# 백엔드 문서 유효성 검사
./script/validate-entb.sh documents/backend/ENTB-XXX-XXXX.md

# 프론트엔드 문서 유효성 검사
./script/validate-entf.sh documents/frontend/ENTF-XXX-XXXX.md
```

유효성 검사에서 오류가 발생하면 문서의 어떤 부분이 누락되었는지 알려줍니다.

### 문서 수동 생성

로컬에서 문서를 수동으로 생성하려면 다음 명령어를 사용합니다:

```bash
# 백엔드 문서 파싱
./script/parsing-entb.sh documents/backend/ENTB-XXX-XXXX.md

# 프론트엔드 문서 파싱
./script/parsing-entf.sh documents/frontend/ENTF-XXX-XXXX.md
```

## 자동화 워크플로우

### Git 훅 (로컬)

`pre-commit` 훅은 다음 작업을 수행합니다:

1. 커밋하려는 백엔드/프론트엔드 문서 파일을 검색합니다.
2. 각 문서 파일에 대해 유효성 검사를 실행합니다.
3. 유효성 검사에 실패한 파일이 있으면 커밋을 중단합니다.
4. 모든 파일이 유효성 검사를 통과하면 커밋을 허용합니다.

### GitHub Actions (원격)

GitHub Actions 워크플로우는 다음 작업을 수행합니다:

1. 푸시된 커밋에서 변경된 백엔드/프론트엔드 문서 파일을 검색합니다.
2. 각 문서 파일에 대해 유효성 검사를 실행합니다.
3. 유효성 검사를 통과한 파일은 자동으로 파싱하여 API/컴포넌트/함수 문서를 생성합니다.
4. 생성된 문서 파일을 자동으로 커밋하여 저장소에 추가합니다.

## 문서 템플릿

### 백엔드 문서 템플릿

백엔드 문서 템플릿은 `documents/templates/backend/ENTB-XXX-XXXX.md`에서 확인할 수 있습니다.

주요 섹션:
- 요약
- 동기 및 목표
- 기술 설계
  - 데이터 모델
  - API 엔드포인트 설계
  - API 오류 반환
- 의존성
- 트러블슈팅
- 대안 검토
- 보안 고려 사항

### 프론트엔드 문서 템플릿

프론트엔드 문서 템플릿은 `documents/templates/frontend/ENTF-XXX-XXXX.md`에서 확인할 수 있습니다.

주요 섹션:
- 요약
- 동기 및 목표
- 기술 설계
  - 컴포넌트 구조
  - Props Interface
  - State Interface
  - API 인터페이스
- 의존성
- 트러블슈팅
- 대안 검토
- 보안 고려 사항

## 기여 방법

1. 이 저장소를 포크합니다.
2. 기능 브랜치를 생성합니다. (`git checkout -b feature/amazing-feature`)
3. 변경 사항을 커밋합니다. (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시합니다. (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다.
