---
layout: default
title: 인터페이스 설계
parent: High Level Design
nav_order: 3
---

# 인터페이스 설계 (Interface Design)
{: .no_toc }

CI Hub 내부 REST API 및 외부 시스템(GitHub, Jenkins, SonarQube, Keycloak) 연동 인터페이스를 정의합니다.
{: .fs-6 .fw-300 }

---

## 목차
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. API 설계 원칙

### 1.1 RESTful 설계 원칙

- **리소스 중심 URL**: 동사 대신 명사 사용 (`/api/projects`, `/api/projects/{id}/jenkins`)
- **HTTP 메서드**: GET(조회), POST(생성), PUT(등록/갱신), DELETE(삭제)
- **상태 코드**: 표준 HTTP 상태 코드 사용
- **JSON 형식**: 모든 요청/응답은 `application/json`
- **복수형 명사**: 컬렉션 리소스는 복수형 (`/projects`, `/tokens`)

### 1.2 인증 방식

모든 `/api/**` 엔드포인트는 Keycloak에서 발급한 JWT Bearer 토큰이 필요합니다.

```
Authorization: Bearer <Keycloak Access Token>
```

- 관리자 전용 엔드포인트(`/api/admin/**`)는 JWT에 `ROLE_ADMIN` 클레임이 필요합니다.
- 토큰 만료 시 `401 Unauthorized` 반환, 클라이언트가 갱신 처리합니다.

### 1.3 버전 관리

- MVP: `/api/` 접두사 사용 (버전 미포함)
- Breaking Change 발생 시 `/api/v2/` 도입
- `OpenAPI 3.0` 명세 자동 생성 (`/swagger-ui.html`)

### 1.4 표준 응답 구조

**성공 응답**:
```json
// 단일 리소스
{
  "id": 1,
  "name": "my-project",
  ...
}

// 컬렉션
{
  "content": [...],
  "totalElements": 10,
  "totalPages": 1,
  "page": 0,
  "size": 20
}
```

**에러 응답**:
```json
{
  "timestamp": "2026-02-19T10:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "프로젝트 이름이 이미 존재합니다.",
  "path": "/api/projects"
}
```

### 1.5 HTTP 상태 코드

| 코드 | 용도 |
|------|------|
| `200 OK` | 조회, 삭제 성공 |
| `201 Created` | 생성 성공 |
| `400 Bad Request` | 입력 유효성 검사 실패 |
| `401 Unauthorized` | 인증 토큰 없음 또는 만료 |
| `403 Forbidden` | 권한 없음 (다른 사용자 프로젝트, 관리자 전용 API) |
| `404 Not Found` | 리소스 없음 |
| `409 Conflict` | 중복 리소스 (프로젝트명 중복 등) |
| `500 Internal Server Error` | 서버 오류 |
| `502 Bad Gateway` | 외부 API(GitHub/Jenkins/SonarQube) 호출 실패 |
| `504 Gateway Timeout` | 외부 API 호출 타임아웃 |

---

## 2. CI Hub REST API 엔드포인트

### 2.1 인증 API

Keycloak OIDC를 통한 인증이며, 별도 로그인 API가 없습니다. 프론트엔드에서 Keycloak 리다이렉트를 직접 처리합니다. 백엔드는 현재 사용자 정보 조회만 제공합니다.

| 메서드 | 경로 | 설명 | 인증 |
|--------|------|------|------|
| `GET` | `/api/auth/me` | 현재 로그인 사용자 정보 조회 | ✅ |

**GET /api/auth/me 응답**:
```json
// 200 OK
{
  "id": "keycloak-user-uuid",
  "email": "developer@example.com",
  "name": "홍길동",
  "roles": ["ROLE_USER"]
}
```

---

### 2.2 프로젝트 API

#### GET /api/projects - 프로젝트 목록 조회

현재 로그인 사용자의 프로젝트 목록을 반환합니다.

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/projects` | ✅ |

**응답 예시**:
```json
// 200 OK
[
  {
    "id": 1,
    "name": "my-spring-app",
    "githubRepoUrl": "https://github.com/myorg/my-spring-app",
    "techStack": "JAVA_SPRING_BOOT",
    "createdAt": "2026-02-19T09:00:00Z",
    "ciStatus": {
      "jenkins": "CREATED",
      "githubActions": "NOT_CONFIGURED",
      "sonarqube": "NOT_CONFIGURED"
    }
  },
  {
    "id": 2,
    "name": "my-react-app",
    "githubRepoUrl": "https://github.com/myorg/my-react-app",
    "techStack": "TYPESCRIPT_REACT",
    "createdAt": "2026-02-19T10:00:00Z",
    "ciStatus": {
      "jenkins": "NOT_CONFIGURED",
      "githubActions": "CREATED",
      "sonarqube": "CREATED"
    }
  }
]
```

**CI 상태 값**:
- `NOT_CONFIGURED`: 미설정
- `CREATING`: 생성 중
- `CREATED`: 생성 완료
- `FAILED`: 생성 실패

---

#### POST /api/projects - 프로젝트 생성

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `POST` | `/api/projects` | ✅ |

**요청 바디**:
```json
{
  "name": "my-spring-app",
  "githubRepoUrl": "https://github.com/myorg/my-spring-app",
  "techStack": "JAVA_SPRING_BOOT"
}
```

**techStack 허용 값**:
- `JAVA_SPRING_BOOT`
- `TYPESCRIPT_REACT`
- `NODEJS`
- `JAVASCRIPT_ANGULAR`

**필드 유효성 검사**:

| 필드 | 제약 |
|------|------|
| `name` | 필수, 3-100자, 영문·숫자·하이픈·언더스코어만 허용 |
| `githubRepoUrl` | 필수, `https://github.com/{owner}/{repo}` 형식 |
| `techStack` | 필수, 허용된 enum 값 중 하나 |

**응답 예시**:
```json
// 201 Created
{
  "id": 1,
  "name": "my-spring-app",
  "githubRepoUrl": "https://github.com/myorg/my-spring-app",
  "techStack": "JAVA_SPRING_BOOT",
  "createdAt": "2026-02-19T09:00:00Z",
  "ciStatus": {
    "jenkins": "NOT_CONFIGURED",
    "githubActions": "NOT_CONFIGURED",
    "sonarqube": "NOT_CONFIGURED"
  }
}
```

**에러 케이스**:
- `400`: 입력 유효성 검사 실패
- `409`: 동일 이름의 프로젝트가 이미 존재

---

#### GET /api/projects/{id} - 프로젝트 상세 조회

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/projects/{id}` | ✅ |

**응답 예시**:
```json
// 200 OK
{
  "id": 1,
  "name": "my-spring-app",
  "githubRepoUrl": "https://github.com/myorg/my-spring-app",
  "techStack": "JAVA_SPRING_BOOT",
  "createdAt": "2026-02-19T09:00:00Z",
  "ciConfig": {
    "jenkins": {
      "status": "CREATED",
      "jobName": "my-spring-app",
      "jobUrl": "http://jenkins.example.com/job/my-spring-app",
      "configuredAt": "2026-02-19T09:30:00Z"
    },
    "githubActions": {
      "status": "CREATED",
      "prUrl": "https://github.com/myorg/my-spring-app/pull/1",
      "branchName": "feature/ci-setup-1708333200",
      "workflowPath": ".github/workflows/ci.yml",
      "configuredAt": "2026-02-19T09:40:00Z"
    },
    "sonarqube": {
      "status": "NOT_CONFIGURED",
      "projectUrl": null,
      "projectKey": null,
      "configuredAt": null
    }
  }
}
```

**에러 케이스**:
- `403`: 다른 사용자의 프로젝트에 접근
- `404`: 프로젝트 없음

---

#### DELETE /api/projects/{id} - 프로젝트 삭제

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `DELETE` | `/api/projects/{id}` | ✅ |

**응답**:
```json
// 200 OK
{
  "message": "프로젝트가 삭제되었습니다. 외부 CI 도구(GitHub Actions, Jenkins Job, SonarQube 프로젝트)는 수동으로 삭제해주세요."
}
```

**에러 케이스**:
- `403`: 다른 사용자의 프로젝트
- `404`: 프로젝트 없음

---

### 2.3 Jenkins API (Phase 1)

#### POST /api/projects/{id}/jenkins - Jenkins Job 생성

| 메서드 | 경로 | 인증 | Phase |
|--------|------|------|-------|
| `POST` | `/api/projects/{id}/jenkins` | ✅ | 1 |

**요청 바디**: 없음 (프로젝트 기술 스택 및 공통 토큰 자동 사용)

**처리 흐름**:

```mermaid
sequenceDiagram
    participant Client
    participant API as Spring Boot API
    participant Jenkins

    Client->>API: POST /api/projects/1/jenkins
    Note over API: 프로젝트 소유권 확인
    Note over API: 공통 Jenkins 토큰 복호화
    Note over API: 기술 스택별 Job XML 템플릿 선택
    API->>Jenkins: POST /createItem?name=my-spring-app
    Jenkins-->>API: 201 Created
    API->>Jenkins: 설정 검증
    API-->>Client: 201 Created + Jenkins Job 정보
```

**응답 예시**:
```json
// 201 Created
{
  "status": "CREATED",
  "jobName": "my-spring-app",
  "jobUrl": "http://jenkins.example.com/job/my-spring-app",
  "configuredAt": "2026-02-19T09:30:00Z"
}
```

**에러 케이스**:
- `404`: 프로젝트 없음
- `409`: 이미 Jenkins Job이 설정됨
- `502`: Jenkins 토큰 미등록 또는 Jenkins API 호출 실패
- `504`: Jenkins 서버 응답 없음 (10초 타임아웃)

---

#### GET /api/projects/{id}/jenkins - Jenkins 상태 조회

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/projects/{id}/jenkins` | ✅ |

**응답 예시**:
```json
// 200 OK
{
  "status": "CREATED",
  "jobName": "my-spring-app",
  "jobUrl": "http://jenkins.example.com/job/my-spring-app",
  "lastBuildStatus": "SUCCESS",
  "configuredAt": "2026-02-19T09:30:00Z"
}
```

```json
// Jenkins Job이 설정되지 않은 경우
{
  "status": "NOT_CONFIGURED"
}
```

---

### 2.4 GitHub Actions API (Phase 2)

#### POST /api/projects/{id}/github-actions - GitHub Actions Workflow 생성

| 메서드 | 경로 | 인증 | Phase |
|--------|------|------|-------|
| `POST` | `/api/projects/{id}/github-actions` | ✅ | 2 |

**요청 바디**: 없음 (프로젝트 기술 스택 및 공통 GitHub App 토큰 자동 사용)

**응답 예시**:
```json
// 201 Created
{
  "status": "CREATED",
  "prUrl": "https://github.com/myorg/my-spring-app/pull/1",
  "branchName": "feature/ci-setup-1708333200",
  "workflowPath": ".github/workflows/ci.yml",
  "configuredAt": "2026-02-19T09:40:00Z"
}
```

**에러 케이스**:
- `404`: 프로젝트 없음
- `409`: 이미 GitHub Actions가 설정됨
- `502`: GitHub App 토큰 미등록, GitHub App 미설치, 또는 GitHub API 호출 실패
- `504`: GitHub API 응답 없음 (20초 타임아웃)

---

#### GET /api/projects/{id}/github-actions - GitHub Actions 상태 조회

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/projects/{id}/github-actions` | ✅ |

**응답 예시**:
```json
// 200 OK
{
  "status": "CREATED",
  "prUrl": "https://github.com/myorg/my-spring-app/pull/1",
  "prStatus": "OPEN",
  "branchName": "feature/ci-setup-1708333200",
  "workflowPath": ".github/workflows/ci.yml",
  "configuredAt": "2026-02-19T09:40:00Z"
}
```

**prStatus 값**: `OPEN`, `MERGED`, `CLOSED`

---

### 2.5 SonarQube API (Phase 3)

#### POST /api/projects/{id}/sonarqube - SonarQube 프로젝트 생성

| 메서드 | 경로 | 인증 | Phase |
|--------|------|------|-------|
| `POST` | `/api/projects/{id}/sonarqube` | ✅ | 3 |

**요청 바디**: 없음 (프로젝트 정보 및 공통 토큰 자동 사용)

**응답 예시**:
```json
// 201 Created
{
  "status": "CREATED",
  "projectKey": "my-spring-app",
  "projectUrl": "http://sonarqube.example.com/dashboard?id=my-spring-app",
  "configuredAt": "2026-02-19T09:50:00Z"
}
```

**에러 케이스**:
- `404`: 프로젝트 없음
- `409`: 이미 SonarQube가 설정됨
- `502`: SonarQube 토큰 미등록 또는 SonarQube API 호출 실패
- `504`: SonarQube 서버 응답 없음 (15초 타임아웃)

---

#### GET /api/projects/{id}/sonarqube - SonarQube 상태 조회

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/projects/{id}/sonarqube` | ✅ |

**응답 예시**:
```json
// 200 OK
{
  "status": "CREATED",
  "projectKey": "my-spring-app",
  "projectUrl": "http://sonarqube.example.com/dashboard?id=my-spring-app",
  "qualityGateStatus": "OK",
  "configuredAt": "2026-02-19T09:50:00Z"
}
```

**qualityGateStatus 값**: `OK`, `WARN`, `ERROR`, `NONE` (분석 미실행)

---

### 2.6 관리자 토큰 API

모든 `/api/admin/**` 엔드포인트는 `ROLE_ADMIN` 역할 필요.

#### GET /api/admin/tokens - 등록된 토큰 목록 조회

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/api/admin/tokens` | ✅ 관리자 |

**응답 예시**:
```json
// 200 OK
[
  {
    "toolType": "JENKINS",
    "serverUrl": "http://jenkins.example.com",
    "username": "admin",
    "isRegistered": true,
    "registeredAt": "2026-02-01T09:00:00Z",
    "lastUsedAt": "2026-02-19T09:30:00Z"
  },
  {
    "toolType": "GITHUB",
    "serverUrl": null,
    "username": null,
    "isRegistered": true,
    "registeredAt": "2026-02-01T09:10:00Z",
    "lastUsedAt": "2026-02-19T09:40:00Z"
  },
  {
    "toolType": "SONARQUBE",
    "serverUrl": null,
    "username": null,
    "isRegistered": false,
    "registeredAt": null,
    "lastUsedAt": null
  }
]
```

> 토큰 값(암호화된 값 포함)은 절대 응답에 포함되지 않습니다.

---

#### PUT /api/admin/tokens/jenkins - Jenkins 공통 토큰 등록/갱신

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `PUT` | `/api/admin/tokens/jenkins` | ✅ 관리자 |

**요청 바디**:
```json
{
  "serverUrl": "http://jenkins.example.com",
  "username": "admin",
  "apiToken": "11abc123def456ghi789"
}
```

**처리 흐름**:
1. Jenkins API 호출로 토큰 유효성 검증 (`GET {serverUrl}/api/json`)
2. AES-256-GCM 암호화
3. DB 저장 (기존 토큰이 있으면 갱신)

**응답 예시**:
```json
// 200 OK
{
  "message": "Jenkins 공통 토큰이 등록되었습니다.",
  "toolType": "JENKINS",
  "serverUrl": "http://jenkins.example.com",
  "registeredAt": "2026-02-19T10:00:00Z"
}
```

---

#### PUT /api/admin/tokens/github - GitHub App 공통 토큰 등록/갱신

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `PUT` | `/api/admin/tokens/github` | ✅ 관리자 |

**요청 바디**:
```json
{
  "appId": "123456",
  "privateKey": "-----BEGIN RSA PRIVATE KEY-----\n..."
}
```

**처리 흐름**:
1. GitHub App JWT 생성 및 Installation Token 발급 테스트
2. AES-256-GCM 암호화
3. DB 저장

**응답 예시**:
```json
// 200 OK
{
  "message": "GitHub App 공통 토큰이 등록되었습니다.",
  "toolType": "GITHUB",
  "registeredAt": "2026-02-19T10:00:00Z"
}
```

---

#### PUT /api/admin/tokens/sonarqube - SonarQube 공통 토큰 등록/갱신

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `PUT` | `/api/admin/tokens/sonarqube` | ✅ 관리자 |

**요청 바디**:
```json
{
  "serverUrl": "http://sonarqube.example.com",
  "apiToken": "sqp_abc123def456"
}
```

**응답 예시**:
```json
// 200 OK
{
  "message": "SonarQube 공통 토큰이 등록되었습니다.",
  "toolType": "SONARQUBE",
  "serverUrl": "http://sonarqube.example.com",
  "registeredAt": "2026-02-19T10:00:00Z"
}
```

---

#### DELETE /api/admin/tokens/{type} - 공통 토큰 삭제

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `DELETE` | `/api/admin/tokens/{type}` | ✅ 관리자 |

**경로 변수** `type`: `jenkins`, `github`, `sonarqube`

**응답 예시**:
```json
// 200 OK
{
  "message": "Jenkins 공통 토큰이 삭제되었습니다. 이후 Jenkins 설정 생성이 불가능합니다."
}
```

---

### 2.7 헬스 체크 API (공개)

| 메서드 | 경로 | 인증 |
|--------|------|------|
| `GET` | `/actuator/health` | ❌ |

**응답 예시**:
```json
// 200 OK
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

---

## 3. 외부 시스템 연동

### 3.1 Keycloak 연동 (OIDC)

```mermaid
sequenceDiagram
    participant Browser
    participant SpringBoot as Spring Boot
    participant Keycloak

    Note over Browser, Keycloak: 로그인 플로우 (Authorization Code Flow)
    Browser->>Keycloak: GET /realms/ci-hub/protocol/openid-connect/auth<br/>?client_id=ci-hub-frontend<br/>&redirect_uri=http://localhost:8080/callback<br/>&response_type=code
    Keycloak-->>Browser: 로그인 페이지
    Browser->>Keycloak: 사용자 자격증명 제출
    Keycloak-->>Browser: Redirect + authorization_code

    Browser->>Keycloak: POST /realms/ci-hub/protocol/openid-connect/token<br/>(code 교환)
    Keycloak-->>Browser: access_token + refresh_token

    Note over Browser, SpringBoot: API 호출
    Browser->>SpringBoot: GET /api/projects<br/>Authorization: Bearer <access_token>
    SpringBoot->>Keycloak: GET /realms/ci-hub/protocol/openid-connect/certs<br/>(JWKS, 캐싱)
    Keycloak-->>SpringBoot: 공개키 (RSA)
    Note over SpringBoot: JWT 서명 검증 + 만료 확인 + 역할 추출
    SpringBoot-->>Browser: 200 OK + 프로젝트 목록
```

**연동 정보**:

| 항목 | 값 |
|------|-----|
| **프로토콜** | OpenID Connect 1.0 / OAuth 2.0 |
| **Grant Type** | Authorization Code Flow (with PKCE) |
| **Realm** | `ci-hub` |
| **Client ID** | `ci-hub-frontend` (Public Client) |
| **Scope** | `openid profile email roles` |
| **Access Token TTL** | 30분 (Keycloak 설정) |
| **Refresh Token TTL** | 24시간 (Keycloak 설정) |

**Keycloak 주요 엔드포인트**:

| 목적 | 엔드포인트 |
|------|----------|
| 인증 요청 | `GET /realms/ci-hub/protocol/openid-connect/auth` |
| 토큰 교환 | `POST /realms/ci-hub/protocol/openid-connect/token` |
| 토큰 갱신 | `POST /realms/ci-hub/protocol/openid-connect/token` (refresh_token) |
| 사용자 정보 | `GET /realms/ci-hub/protocol/openid-connect/userinfo` |
| 공개키(JWKS) | `GET /realms/ci-hub/protocol/openid-connect/certs` |
| 로그아웃 | `GET /realms/ci-hub/protocol/openid-connect/logout` |

---

### 3.2 GitHub API 연동 (GitHub App)

```mermaid
sequenceDiagram
    participant BE as Spring Boot
    participant GH as GitHub API

    Note over BE, GH: GitHub App 인증 (JWT → Installation Token)
    BE->>BE: GitHub App Private Key로 JWT 생성 (10분 유효)
    BE->>GH: POST /app/installations/{id}/access_tokens<br/>Authorization: Bearer <JWT>
    GH-->>BE: Installation Access Token (1시간 유효)

    Note over BE, GH: Repository 작업
    BE->>GH: GET /repos/{owner}/{repo}<br/>Authorization: Bearer <installation_token>
    GH-->>BE: Repository 정보
    BE->>GH: POST /repos/{owner}/{repo}/git/refs<br/>(브랜치 생성)
    GH-->>BE: 201 Created
    BE->>GH: PUT /repos/{owner}/{repo}/contents/.github/workflows/ci.yml<br/>(파일 커밋)
    GH-->>BE: 201 Created
    BE->>GH: POST /repos/{owner}/{repo}/pulls<br/>(PR 생성)
    GH-->>BE: PR 정보 (url, number)
```

**연동 정보**:

| 항목 | 값 |
|------|-----|
| **API 버전** | GitHub REST API v3 |
| **Base URL** | `https://api.github.com` |
| **인증 방식** | GitHub App JWT → Installation Access Token |
| **Rate Limit** | 15,000 req/시간 (설치당) |
| **타임아웃** | 20초 |

**주요 API 엔드포인트**:

| 목적 | 메서드 | 엔드포인트 |
|------|--------|------------|
| Installation Token 발급 | POST | `/app/installations/{id}/access_tokens` |
| Repository 정보 조회 | GET | `/repos/{owner}/{repo}` |
| 브랜치 생성 | POST | `/repos/{owner}/{repo}/git/refs` |
| 파일 생성/수정 (커밋) | PUT | `/repos/{owner}/{repo}/contents/{path}` |
| PR 생성 | POST | `/repos/{owner}/{repo}/pulls` |
| PR 상태 조회 | GET | `/repos/{owner}/{repo}/pulls/{number}` |
| GitHub Secret 등록 | PUT | `/repos/{owner}/{repo}/actions/secrets/{name}` |

**에러 처리**:

| HTTP 코드 | 원인 | CI Hub 처리 |
|-----------|------|-------------|
| `401` | 토큰 만료 또는 Invalid | Installation Token 재발급 |
| `403` | Repository 권한 없음 | 사용자에게 GitHub App 설치 안내 |
| `404` | Repository 없음 | 사용자에게 URL 확인 요청 |
| `422` | 브랜치 이미 존재 | 타임스탬프로 새 브랜치명 생성 |

---

### 3.3 Jenkins API 연동

```mermaid
sequenceDiagram
    participant BE as Spring Boot
    participant JK as Jenkins API

    Note over BE, JK: 연결 검증 (토큰 등록 시)
    BE->>JK: GET {jenkinsUrl}/api/json<br/>Authorization: Basic base64(username:apiToken)
    JK-->>BE: 200 OK (Jenkins 정보)

    Note over BE, JK: Jenkins Job 생성
    BE->>JK: POST {jenkinsUrl}/createItem?name=my-spring-app<br/>Content-Type: application/xml<br/>(Job Config XML)
    JK-->>BE: 200 OK (Job 생성 성공)

    Note over BE, JK: Job 상태 조회
    BE->>JK: GET {jenkinsUrl}/job/my-spring-app/api/json
    JK-->>BE: Job 정보
```

**연동 정보**:

| 항목 | 값 |
|------|-----|
| **API 버전** | Jenkins 2.x REST API |
| **인증 방식** | HTTP Basic Auth (`username:api-token`, Base64 인코딩) |
| **Content-Type** | Job 생성 시 `application/xml`, 조회 시 `application/json` |
| **타임아웃** | 10초 |

**주요 API 엔드포인트**:

| 목적 | 메서드 | 엔드포인트 |
|------|--------|------------|
| 연결 검증 | GET | `{jenkinsUrl}/api/json` |
| Job 생성 | POST | `{jenkinsUrl}/createItem?name={name}` |
| Job 설정 조회 | GET | `{jenkinsUrl}/job/{name}/config.xml` |
| Job 정보 조회 | GET | `{jenkinsUrl}/job/{name}/api/json` |
| 최근 빌드 상태 | GET | `{jenkinsUrl}/job/{name}/lastBuild/api/json` |

**에러 처리**:

| HTTP 코드 | 원인 | CI Hub 처리 |
|-----------|------|-------------|
| `401` | API 토큰 오류 | 토큰 재등록 안내 |
| `400` | 동일 Job 이름 존재 | Suffix 추가 (`-2`, `-3`) |
| 연결 불가 | Jenkins 서버 다운 | 사용자에게 서버 상태 확인 요청 |

---

### 3.4 SonarQube API 연동

```mermaid
sequenceDiagram
    participant BE as Spring Boot
    participant SQ as SonarQube API

    Note over BE, SQ: 프로젝트 생성
    BE->>SQ: POST {sqUrl}/api/projects/create<br/>Authorization: Bearer {token}<br/>project={key}&name={name}
    SQ-->>BE: 200 OK + 프로젝트 정보

    Note over BE, SQ: 분석 토큰 생성
    BE->>SQ: POST {sqUrl}/api/user_tokens/generate<br/>name={tokenName}&projectKey={key}
    SQ-->>BE: 분석 토큰 (1회만 반환)

    Note over BE, SQ: GitHub 연동 설정
    BE->>SQ: POST {sqUrl}/api/alm_settings/set_github_binding<br/>project={key}&almSetting={config}
    SQ-->>BE: 200 OK

    Note over BE, SQ: Quality Gate 상태 조회
    BE->>SQ: GET {sqUrl}/api/qualitygates/project_status?projectKey={key}
    SQ-->>BE: Quality Gate 상태
```

**연동 정보**:

| 항목 | 값 |
|------|-----|
| **API 버전** | SonarQube 9.x+ Web API |
| **인증 방식** | Bearer Token (HTTP Header: `Authorization: Bearer {token}`) |
| **Edition** | Community Edition (자체 호스팅) |
| **타임아웃** | 15초 |

**주요 API 엔드포인트**:

| 목적 | 메서드 | 엔드포인트 |
|------|--------|------------|
| 연결 검증 | GET | `{sqUrl}/api/system/status` |
| 프로젝트 생성 | POST | `{sqUrl}/api/projects/create` |
| 분석 토큰 생성 | POST | `{sqUrl}/api/user_tokens/generate` |
| Quality Gate 상태 | GET | `{sqUrl}/api/qualitygates/project_status?projectKey={key}` |
| GitHub 연동 설정 | POST | `{sqUrl}/api/alm_settings/set_github_binding` |
| 프로젝트 존재 확인 | GET | `{sqUrl}/api/projects/search?projects={key}` |

**에러 처리**:

| HTTP 코드 | 원인 | CI Hub 처리 |
|-----------|------|-------------|
| `401` | API 토큰 오류 | 토큰 재등록 안내 |
| `400` | 프로젝트 키 중복 | Suffix 추가 |
| 연결 불가 | SonarQube 서버 다운 | 사용자에게 서버 상태 확인 요청 |

---

## 4. 메시징 패턴

### 4.1 동기 통신 (MVP 범위)

MVP 단계에서는 모든 CI 설정 생성을 동기 HTTP 요청으로 처리합니다.

```
프론트엔드 → REST API → 외부 CI API 호출 → DB 저장 → 응답
```

- CI 도구 API 응답 시간이 긴 경우 타임아웃 설정으로 사용자 경험 보호
- 타임아웃 발생 시 `504 Gateway Timeout` 반환 및 안내 메시지 제공

### 4.2 비동기 처리 고려 (향후)

동시 10개 이상의 CI 설정 생성 요청이 빈번해지면 비동기 Job Queue 도입 검토:

```mermaid
graph LR
    API[REST API] -->|Job 등록| Queue[(Job Queue)]
    Queue -->|처리| Worker[Background Worker]
    Worker -->|결과 저장| DB[(PostgreSQL)]
    FE[Frontend] -->|폴링| API
```

---

## 5. API 전체 요약

### 5.1 엔드포인트 목록

| 메서드 | 경로 | 설명 | 역할 |
|--------|------|------|------|
| `GET` | `/api/auth/me` | 현재 사용자 정보 | 일반 |
| `GET` | `/api/projects` | 프로젝트 목록 | 일반 |
| `POST` | `/api/projects` | 프로젝트 생성 | 일반 |
| `GET` | `/api/projects/{id}` | 프로젝트 상세 | 일반 |
| `DELETE` | `/api/projects/{id}` | 프로젝트 삭제 | 일반 |
| `POST` | `/api/projects/{id}/jenkins` | Jenkins Job 생성 | 일반 (Phase 1) |
| `GET` | `/api/projects/{id}/jenkins` | Jenkins 상태 조회 | 일반 (Phase 1) |
| `POST` | `/api/projects/{id}/github-actions` | GitHub Actions 생성 | 일반 (Phase 2) |
| `GET` | `/api/projects/{id}/github-actions` | GitHub Actions 상태 | 일반 (Phase 2) |
| `POST` | `/api/projects/{id}/sonarqube` | SonarQube 생성 | 일반 (Phase 3) |
| `GET` | `/api/projects/{id}/sonarqube` | SonarQube 상태 | 일반 (Phase 3) |
| `GET` | `/api/admin/tokens` | 토큰 목록 조회 | 관리자 |
| `PUT` | `/api/admin/tokens/jenkins` | Jenkins 토큰 등록 | 관리자 |
| `PUT` | `/api/admin/tokens/github` | GitHub 토큰 등록 | 관리자 |
| `PUT` | `/api/admin/tokens/sonarqube` | SonarQube 토큰 등록 | 관리자 |
| `DELETE` | `/api/admin/tokens/{type}` | 토큰 삭제 | 관리자 |
| `GET` | `/actuator/health` | 헬스 체크 | 공개 |

---

## ✅ 완료 체크리스트

- [x] API 설계 원칙 정의 완료 (RESTful, 인증, 버전 관리, 표준 응답)
- [x] 인증 API 정의 완료 (/api/auth/me)
- [x] 프로젝트 CRUD API 정의 완료
- [x] Jenkins CI 설정 API 정의 완료 (Phase 1)
- [x] GitHub Actions CI 설정 API 정의 완료 (Phase 2)
- [x] SonarQube CI 설정 API 정의 완료 (Phase 3)
- [x] 관리자 토큰 관리 API 정의 완료
- [x] Keycloak OIDC 연동 방식 정의 완료
- [x] GitHub App 연동 방식 정의 완료
- [x] Jenkins REST API 연동 방식 정의 완료
- [x] SonarQube Web API 연동 방식 정의 완료
- [x] 에러 처리 정책 정의 완료
- [x] API 전체 요약 테이블 작성 완료
