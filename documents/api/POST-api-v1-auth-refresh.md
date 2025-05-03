# POST api/v1/auth/refresh

## Overview
이 문서는 사용자 인증을 위한 REST API 개발에 관한 설계를 기술합니다. 회원가입, 로그인, 토큰 갱신, 비밀번호 재설정 기능을 포함합니다.

## API Endpoint Details

- **Method:** POST
- **Path:** api/v1/auth/refresh
- **Path Parameters:** None
- **Authentication Required:** Public
- **Request Object:** TokenRefreshRequest
- **Response Object:** AuthResponse

## Request Model
```java
public class SignupRequest {
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    @Size(min = 8, max = 30)
    private String password;
    
    @NotBlank
    private String firstName;
    
    @NotBlank
    private String lastName;
    
    // Getters and Setters
}

public class LoginRequest {
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    private String password;
    
    // Getters and Setters
}

public class TokenRefreshRequest {
    @NotBlank
    private String refreshToken;
    
    // Getters and Setters
}

public class PasswordResetRequest {
    @NotBlank
    @Email
    private String email;
    
    // Getters and Setters
}
```

## Response Model
```java
public class AuthResponse {
    private String tokenType = "Bearer";
    private String accessToken;
    private String refreshToken;
    private Long expiresIn;
    
    // Getters and Setters
}

public class MessageResponse {
    private String message;
    
    // Getters and Setters
}
```

## Dependencies
- "org.springframework.boot:spring-boot-starter-security"
- "org.springframework.boot:spring-boot-starter-data-jpa"
- "io.jsonwebtoken:jjwt-api:0.11.5"
- "io.jsonwebtoken:jjwt-impl:0.11.5"
- "io.jsonwebtoken:jjwt-jackson:0.11.5"
- "org.springframework.boot:spring-boot-starter-mail"
