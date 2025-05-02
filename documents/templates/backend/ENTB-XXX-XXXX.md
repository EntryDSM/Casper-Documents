# ENTB-XXX-XXXX: 백엔드 개발 기능 제목

---
## 요약
이 가 제안하는 백엔드 개발 기능에 대한 간략한 요약을 제공하세요.

---
## 동기
이 백엔드 개발 기능이 필요한 이유와 해결하려는 문제점을 설명하세요.

### 목표
이 백엔드 개발 기능이 달성하고자 하는 구체적인 목표를 나열하세요.
- 목표

### 목표가 아닌 것
이 백엔드 개발 기능의 범위에 포함되지 않는 것을 명확히 하세요.
- 비목표

---
## 제안
백엔드 개발 기능의 구현에 대한 상세한 설명을 제공하세요.

### 기술 설계
백엔드 구현을 위한 기술적 설계를 설명하세요.

데이터 모델 :

형식 :
```
Entity
<코드를 복사 붙혀넣기 해주세요.>
```
```
Request Object
<코드를 복사 붙혀넣기 해주세요.>
```
```
Response Object
<코드를 복사 붙혀넣기 해주세요.>
```

예시 :


Entity
```kotlin
data class User(
    val id: Long,
    val username: String,
    val email: String,
    val createdAt: LocalDateTime = LocalDateTime.now(),
    val updatedAt: LocalDateTime = LocalDateTime.now(),
    val isActive: Boolean = true
)
```

Request Object
```kotlin
data class CreateUserRequest(
    val username: String,
    val email: String,
    val password: String
)
```

Response Object
```kotlin
data class UserResponse(
    val id: Long,
    val username: String,
    val email: String,
    val createdAt: String,
    val isActive: Boolean
) {
    companion object {
        fun from(user: User): UserResponse {
            return UserResponse(
                id = user.id,
                username = user.username,
                email = user.email,
                createdAt = user.createdAt.toString(),
                isActive = user.isActive
            )
        }
    }
}
```

API 엔드포인트 설계 :

형식 :
```
Type / "Path" / Path Value / Authentication / Request Object Name / Response Object Name
```

예시 :
```
POST / "/api/hello" /  name, age / true / request / response
```

API 오류 반환 :


---
## 검토 설문

### 로깅
백엔드 개발자가 해당 기능이 사용 중인지 어떻게 확인할 수 있나요?

### 의존성
이 백엔드 기능은 특정 서비스나 라이브러리에 의존하나요?
외부 의존성을 나열하고 버전 요구사항을 포함하세요.

형식 :
```
impl "의존성 이름을 입력해주세요,"
```

예시 :
```
impl "org.springframework.boot:spring-boot-starter"
```

### 트러블슈팅
해당 백엔드 기능이 작동하지 않을때 무엇을 확인해야 하나요?
문제 해결을 위한 체크리스트와 단계를 제공하세요.

---
## 대안
고려했던 백엔드 대안적인 접근 방식과 선택하지 않은 이유를 설명하세요.

---
## 보안 고려 사항
이 백엔드 기능과 관련된 보안 위험과 완화 전략을 설명하세요.