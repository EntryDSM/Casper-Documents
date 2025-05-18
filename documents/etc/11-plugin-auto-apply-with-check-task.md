  # ENTB-XXX-XXXX: KDoc 문서화 검사 및 Gradle 플러그인 개발

---

## 요약
- 이 프로젝트는 Kotlin 코드의 KDoc 문서화 누락을 자동으로 감지하는 Gradle 플러그인을 제공합니다.
- 클래스, 객체, 인터페이스, 함수, 속성 등의 코드 요소에 KDoc 주석이 없을 경우 이를 감지하고, 사용자 친화적인 오류 메시지와 함께 빌드 실패를 유도하여 코드 품질을 향상시킵니다.

---

## 동기
- Kotlin 프로젝트에서 문서화는 코드 유지보수와 협업에 필수적입니다.
- 하지만 KDoc 주석 누락은 수작업으로 확인하기 어렵고, 일관성 없는 문서화는 코드 이해를 방해합니다.
- 이를 해결하기 위해 자동화된 문서화 검사 도구가 필요합니다.

### 목표
- 모든 Kotlin 코드 요소(클래스, 객체, 인터페이스, 함수, 속성)에 KDoc 주석이 있는지 확인합니다.
- Gradle 플러그인을 통해 빌드 프로세스에 통합합니다.
- 사용자 친화적인 오류 메시지와 색상 로그를 제공하여 문제를 쉽게 파악할 수 있도록 합니다.
- 모듈별, 파일별 검사 결과를 요약하여 개발자 경험을 개선합니다.

### 목표가 아닌 것
- KDoc 주석의 내용 품질(설명의 정확성, 완전성) 검사
- Kotlin 외 다른 언어(Java, Groovy 등)의 문서화 검사
- 자동 KDoc 주석 생성 기능

---

## 제안
- 이 플러그인은 Gradle 빌드 시스템에 통합되어 Kotlin 소스 파일을 분석하고 KDoc 주석 누락 여부를 확인합니다.

### 주요 구성 요소
- **DocCheckTask**: 특정 코드 요소를 검사하는 Gradle 태스크  
- **DocCheckService**: 소스 파일을 분석하고 문서화 문제를 찾는 서비스  
- **DocReporter**: 검사 결과를 색상 로그로 출력  
- **DocumentationConventionPlugin**: 태스크를 등록하고 빌드 라이프사이클에 연결  

---

## 기술 설계

### 데이터 모델
```kotlin
data class DocumentationProblem(
    val element: CodeElement,   // 문제가 발견된 코드 요소 유형
    val elementName: String,    // 요소의 이름 (클래스명, 함수명 등)
    val filePath: String,       // 파일의 전체 경로
    val fileName: String,       // 파일의 이름 (경로 제외)
    val lineNumber: Int         // 코드 요소가 선언된 줄 번호
) {
    fun toUserFriendlyMessage(): String =
        DocMessageTemplates.USER_FRIENDLY_MESSAGE.format(
            fileName, lineNumber,
            element.helpMessage.format(elementName)
        )
    
    fun toDetailedMessage(): String =
        DocMessageTemplates.DETAILED_MESSAGE.format(
            element.friendlyName, elementName,
            filePath, lineNumber
        )
    
    fun toLogMessage(): String =
        DocMessageTemplates.LOG_MESSAGE.format(
            element.friendlyName, elementName,
            fileName, lineNumber
        )
}
Request Object
API 요청을 처리하지 않으므로 Request Object는 없습니다.
대신 Gradle 태스크 입력으로 CodeElement를 사용합니다:

kotlin
복사
편집
@get:Input
abstract val codeElement: Property<CodeElement>
Response Object
문서화 검사 결과는 DocumentationProblem 리스트로 반환되며, DocReporter를 통해 콘솔에 출력됩니다:

kotlin
복사
편집
data class DocumentationProblem(
    val element: CodeElement,
    val elementName: String,
    val filePath: String,
    val fileName: String,
    val lineNumber: Int
)
Gradle 태스크 설계
checkClassDocs : 클래스 KDoc 검사

checkObjectDocs : 객체 KDoc 검사

checkInterfaceDocs : 인터페이스 KDoc 검사

checkFunctionDocs : 함수 KDoc 검사

checkPropertyDocs : 속성 KDoc 검사

checkAllDocs : 모든 코드 요소 검사

오류 처리
KDoc 주석 누락 시 DocumentationException을 던집니다:

kotlin
복사
편집
throw DocumentationException.missingDocumentation(element)
오류 메시지 예시:

csharp
복사
편집
[File.kt:10] 클래스 'MyClass'에 KDoc 주석이 없습니다.
검토 설문
로깅
Gradle 빌드 로그에서 DocReporter가 출력하는 색상 로그를 확인하여 기능이 사용 중인지 알 수 있습니다.

성공: ✅ 모든 ${element.friendlyName}에 KDoc 주석이 있습니다!

실패: ❌ ${problems.size}개의 ${element.friendlyName}에 KDoc 주석이 없습니다.

진행 상황: 검사 중... (50%) - File.kt

의존성
다음 라이브러리에 의존합니다:

kotlin
복사
편집
impl "org.gradle:gradle-core"
impl "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23"
impl "org.jlleitschuh.gradle:ktlint-gradle:12.1.1"
impl "io.gitlab.arturbosch.detekt:detekt-gradle-plugin:1.23.6"
버전 요구사항:

Gradle 7.0 이상

Kotlin 1.9.23

Java 17 (JVM 타겟)

트러블슈팅
기능이 작동하지 않을 때 확인할 사항:

빌드 실패 로그 확인: DocReporter 출력에서 누락된 KDoc 주석의 파일명, 줄 번호, 요소 이름 확인

소스 파일 경로 확인: src/ 폴더 내 .kt 파일이 올바르게 포함되었는지 확인

태스크 설정 확인: codeElement 속성이 올바르게 설정되었는지 확인

의존성 충돌 확인: Gradle 의존성 버전이 호환되는지 확인 (./gradlew dependencies)

Gradle 캐시 문제: ./gradlew cleanBuildDirs 실행 후 재빌드

KDoc 형식 확인: /** */ 형식이 올바른지, 주석이 요소 직전에 위치했는지 확인

대안
Detekt 또는 Ktlint 확장

고려: 기존 정적 분석 도구(Detekt, Ktlint)에 KDoc 검사 규칙 추가

선택하지 않은 이유: Detekt와 Ktlint는 주로 코드 스타일과 버그 감지에 초점.

IDE 플러그인

고려: IntelliJ IDEA 플러그인으로 KDoc 검사 구현

선택하지 않은 이유: CI/CD 파이프라인에 통합하기 어려움.

스크립트 기반 검사

고려: Bash/Shell 스크립트로 단순 검사

선택하지 않은 이유: 코드 파싱 및 모듈 관리 어려움.

보안 고려 사항
파일 시스템 접근: 플러그인이 소스 파일을 읽으므로, 악의적인 파일 경로 조작 가능성

로그 노출: 민감한 코드 정보(클래스명, 파일 경로)가 로그에 포함될 가능성

완화 전략
파일 경로 검증: project.fileTree API를 사용해 프로젝트 디렉토리 내 파일만 접근

로그 필터링: 민감한 정보(주석 내용)는 로그에서 제외

권한 제한: CI/CD 환경에서 플러그인 실행 시 최소 권한 부여

의존성 보안: 신뢰할 수 있는 Maven Central 저장소만 사용

