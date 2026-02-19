---
layout: default
title: 시스템 아키텍처
parent: High Level Design
nav_order: 1
---

# 시스템 아키텍처 (System Architecture)
{: .no_toc }

CI Hub 시스템의 전체 구조와 기술 스택을 정의합니다.
{: .fs-6 .fw-300 }

---

## 목차
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. 전체 시스템 아키텍처

### 1.1 시스템 컨텍스트 (C4 Level 1)

```mermaid
C4Context
    title CI Hub 시스템 컨텍스트 다이어그램

    Person(developer, "서비스 개발자", "CI 셋업이 필요한 프로젝트 개발자")
    Person(admin, "관리자", "CI 도구 공통 토큰을 등록·관리하는 운영자")

    System(cihub, "CI Hub", "CI 도구(GitHub Actions, Jenkins, SonarQube)를 템플릿 기반으로 자동 셋업하는 허브 시스템")

    System_Ext(keycloak, "Keycloak", "사용자 인증 및 SSO (OpenID Connect)")
    System_Ext(github, "GitHub", "Repository 접근, 브랜치 생성, PR 생성 (GitHub App)")
    System_Ext(jenkins, "Jenkins", "Build Job 생성 및 관리 (REST API)")
    System_Ext(sonarqube, "SonarQube", "코드 품질 분석 프로젝트 생성 (Web API)")

    Rel(developer, cihub, "프로젝트 생성, CI 설정, 상태 확인", "HTTPS")
    Rel(admin, cihub, "CI 도구 공통 토큰 관리", "HTTPS")
    Rel(cihub, keycloak, "사용자 인증 (OIDC)", "HTTPS")
    Rel(cihub, github, "Workflow 파일 커밋, PR 생성", "HTTPS / GitHub App")
    Rel(cihub, jenkins, "Jenkins Job 생성", "HTTP(S) / API Token")
    Rel(cihub, sonarqube, "SonarQube 프로젝트 생성", "HTTP(S) / API Token")
```

### 1.2 컨테이너 다이어그램 (C4 Level 2)

```mermaid
graph TB
    subgraph "사용자"
        Browser[웹 브라우저]
    end

    subgraph "CI Hub - Docker Compose"
        App[CI Hub 앱<br/>Spring Boot 3.x<br/>React SPA 내장 서빙]
        DB[(PostgreSQL 13+<br/>프로젝트 · CI 설정<br/>암호화 토큰)]
        KC[Keycloak<br/>OIDC Identity Provider]
    end

    subgraph "외부 CI 도구"
        GH[GitHub<br/>GitHub App API]
        JK[Jenkins<br/>REST API]
        SQ[SonarQube<br/>Community Edition]
    end

    Browser -->|HTTPS| App
    App -->|JDBC| DB
    App -->|OIDC Token Validation| KC
    Browser -->|OIDC Redirect| KC

    App -->|GitHub App Token - HTTPS| GH
    App -->|API Token Basic Auth| JK
    App -->|API Token Bearer| SQ

    style App fill:#e1f5ff
    style DB fill:#e1ffe1
    style KC fill:#f5e1ff
    style GH fill:#fff4e1
    style JK fill:#ffe1e1
    style SQ fill:#e1fff4
```

**핵심 설계 결정**: React SPA 빌드 결과물을 Spring Boot가 Static Resource로 서빙합니다. 별도 Nginx 또는 CDN 없이 단일 컨테이너로 프론트엔드와 백엔드를 함께 제공합니다.

---

## 2. 레이어 아키텍처

### 2.1 레이어 구조

```mermaid
graph TD
    A[Presentation Layer<br/>React SPA - Static Resource] --> B[Application Layer<br/>Spring Boot REST API]
    B --> C[Domain Layer<br/>비즈니스 로직 및 도메인 모델]
    C --> D[Infrastructure Layer<br/>JPA Repository, 외부 API 클라이언트]

    A1[ProjectListPage] -.-> A
    A2[ProjectCreatePage] -.-> A
    A3[CIStatusPage] -.-> A
    A4[AdminTokenPage] -.-> A

    B1[ProjectController] -.-> B
    B2[CISetupController] -.-> B
    B3[AdminController] -.-> B

    C1[ProjectService] -.-> C
    C2[GitHubActionsService] -.-> C
    C3[JenkinsService] -.-> C
    C4[SonarQubeService] -.-> C
    C5[TokenService<br/>AES-256-GCM] -.-> C

    D1[ProjectRepository<br/>CIConfigRepository] -.-> D
    D2[GitHub API Client] -.-> D
    D3[Jenkins API Client] -.-> D
    D4[SonarQube API Client] -.-> D

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#ffe1e1
    style D fill:#e1ffe1
```

### 2.2 레이어별 책임

| 레이어 | 책임 | 기술 |
|--------|------|------|
| **Presentation** | React SPA 렌더링, 사용자 입력 처리 (Spring Boot가 정적 파일 서빙) | React 18+, TypeScript, React Router |
| **Application** | REST API 엔드포인트, 인증/인가 검증, 입력 유효성 검사 | Spring Boot, Spring Security, Bean Validation |
| **Domain** | 프로젝트 관리, CI 설정 오케스트레이션, 토큰 암호화·복호화 | Kotlin, Domain Services |
| **Infrastructure** | DB 접근, 외부 API(GitHub/Jenkins/SonarQube/Keycloak) 호출 | Spring Data JPA, RestTemplate/WebClient |

---

## 3. 기술 스택

### 3.1 전체 기술 스택

```mermaid
graph LR
    subgraph "Frontend (Static)"
        F1[React 18+]
        F2[TypeScript]
        F3[React Router v6]
        F4[Axios]
    end

    subgraph "Backend"
        B1[Kotlin 1.9+]
        B2[Spring Boot 3.x]
        B3[Spring Security<br/>OIDC]
        B4[Spring Data JPA]
    end

    subgraph "데이터베이스"
        D1[PostgreSQL 13+]
    end

    subgraph "인증"
        A1[Keycloak]
    end

    subgraph "인프라"
        I1[Docker]
        I2[Docker Compose]
        I3[GitHub Actions<br/>자체 CI]
    end

    F1 -->|REST API| B2
    B2 --> D1
    B2 -->|OIDC| A1
    I1 --> I2

    style F1 fill:#e1f5ff
    style B1 fill:#fff4e1
    style D1 fill:#e1ffe1
    style A1 fill:#f5e1ff
    style I1 fill:#ffe1f5
```

### 3.2 상세 기술 스택

#### Frontend

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 프레임워크 | React | 18.x | UI 라이브러리 |
| 언어 | TypeScript | 5.x | 타입 안정성 |
| 라우팅 | React Router | 6.x | SPA 클라이언트 라우팅 |
| HTTP 클라이언트 | Axios | 1.x | REST API 호출 |
| 빌드 | Vite / CRA | - | 번들링 및 정적 파일 생성 |

#### Backend

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 언어 | Kotlin | 1.9+ | JVM 기반 백엔드 언어 |
| 프레임워크 | Spring Boot | 3.x | 애플리케이션 서버 |
| 인증/인가 | Spring Security + OAuth2 Resource Server | - | Keycloak JWT 검증 |
| ORM | Spring Data JPA + Hibernate | - | 데이터베이스 접근 |
| API 문서 | SpringDoc OpenAPI (Swagger UI) | 2.x | REST API 문서화 |
| 암호화 | JDK AES-256-GCM | - | CI 도구 토큰 암호화 |
| 검증 | Bean Validation (jakarta.validation) | - | 입력 유효성 검사 |
| HTTP 클라이언트 | Spring WebClient / RestTemplate | - | 외부 API 호출 |
| 정적 파일 서빙 | Spring Boot Static Resource Handler | - | React SPA 내장 서빙 |
| 모니터링 | Spring Boot Actuator | - | 헬스 체크, 메트릭 |

#### Database 및 인증

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| RDBMS | PostgreSQL | 13+ | 주 데이터베이스 (프로젝트, CI 설정, 토큰) |
| 인증 서버 | Keycloak | 21+ | OIDC Identity Provider |

#### DevOps 및 Infrastructure

| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 컨테이너 | Docker | 24.x | 컨테이너화 |
| 오케스트레이션 | Docker Compose | 3.8+ | 로컬/운영 환경 구성 |
| CI/CD | GitHub Actions | - | 프로젝트 자체 CI 파이프라인 |
| 로깅 | Logback + JSON encoder | - | 구조화된 JSON 로그 |
| 코드 분석 | ktlint, detekt / ESLint, Prettier | - | 정적 코드 분석 |

---

## 4. 배포 아키텍처

### 4.1 Docker Compose 구성

```mermaid
graph TB
    subgraph "Docker Compose Network"
        subgraph "ci-hub-app"
            App[Spring Boot 3.x<br/>포트 8080<br/>React SPA 내장 서빙]
        end

        subgraph "ci-hub-db"
            DB[(PostgreSQL 13+<br/>포트 5432)]
        end

        subgraph "keycloak"
            KC[Keycloak<br/>포트 8180<br/>Realm: ci-hub]
        end
    end

    Browser[웹 브라우저] -->|8080 HTTPS| App
    App -->|5432 JDBC| DB
    App -->|8180 OIDC| KC
    Browser -->|8180 OIDC Redirect| KC

    App -->|HTTPS| GitHub[GitHub API]
    App -->|HTTPS| Jenkins[Jenkins API]
    App -->|HTTPS| SonarQube[SonarQube API]

    style App fill:#e1f5ff
    style DB fill:#e1ffe1
    style KC fill:#f5e1ff
```

### 4.2 환경별 구성

| 환경 | 용도 | 구성 | 비고 |
|------|------|------|------|
| **Local Development** | 개발자 로컬 | Docker Compose (전체 스택) | `.env.local` |
| **CI (GitHub Actions)** | PR 빌드/테스트 | 단위 테스트 + 통합 테스트 | `docker-compose.test.yml` |
| **Production** | 운영 | Docker Compose (단일 서버) | `.env.production` |

### 4.3 Spring Boot Static Resource 서빙 구조

```mermaid
graph LR
    Browser -->|GET /| Spring[Spring Boot]
    Browser -->|GET /api/**| Spring
    Spring -->|Static: /*| React[React Build 결과물<br/>src/main/resources/static/]
    Spring -->|API: /api/**| Controller[REST Controllers]
    Spring -->|SPA Fallback: /**| React
```

- React 빌드 결과물은 `src/main/resources/static/`에 복사하여 내장 서빙
- `/api/**` 경로는 Spring Boot REST Controller가 처리
- 그 외 모든 경로(`/**`)는 `index.html`로 폴백하여 React Router가 처리

---

## 5. 데이터 흐름

### 5.1 GitHub Actions Workflow 생성 흐름

```mermaid
sequenceDiagram
    actor Developer as 서비스 개발자
    participant FE as React SPA
    participant BE as Spring Boot API
    participant DB as PostgreSQL
    participant GH as GitHub API

    Developer->>FE: GitHub Actions 설정 클릭
    FE->>BE: POST /api/projects/{id}/github-actions
    Note over BE: JWT 토큰 검증 (Keycloak)
    BE->>DB: 프로젝트 정보 조회
    DB-->>BE: 프로젝트 (기술 스택, Repository URL)
    BE->>DB: GitHub App 암호화 토큰 조회
    DB-->>BE: 암호화된 토큰
    Note over BE: AES-256-GCM 복호화 (메모리 내)
    BE->>GH: Repository 접근 권한 확인
    GH-->>BE: Repository 메타데이터
    Note over BE: 기술 스택 기반 Workflow 템플릿 선택
    BE->>GH: 새 브랜치 생성 (feature/ci-setup-{timestamp})
    GH-->>BE: 브랜치 생성 완료
    BE->>GH: Workflow YAML 파일 커밋
    GH-->>BE: 커밋 완료
    BE->>GH: Pull Request 생성
    GH-->>BE: PR URL
    BE->>DB: CI 설정 정보 저장 (PR URL, 브랜치명, 상태)
    DB-->>BE: 저장 완료
    BE-->>FE: 201 Created + PR URL
    FE-->>Developer: 설정 완료 (PR 링크 표시)
```

### 5.2 프로젝트 상세 조회 (CI 상태 포함)

```mermaid
sequenceDiagram
    actor Developer as 서비스 개발자
    participant FE as React SPA
    participant BE as Spring Boot API
    participant DB as PostgreSQL
    participant GH as GitHub API
    participant JK as Jenkins API
    participant SQ as SonarQube API

    Developer->>FE: 프로젝트 상세 조회
    FE->>BE: GET /api/projects/{id}
    BE->>DB: 프로젝트 및 CI 설정 조회
    DB-->>BE: 프로젝트 + CI 설정 정보

    par 병렬 상태 확인 (CI 설정이 있는 경우)
        BE->>GH: PR 상태 확인 (선택적)
        GH-->>BE: PR Open/Merged/Closed
    and
        BE->>JK: Job 존재 여부 확인 (선택적)
        JK-->>BE: Job 상태
    and
        BE->>SQ: 프로젝트 존재 여부 확인 (선택적)
        SQ-->>BE: 프로젝트 상태
    end

    BE-->>FE: 200 OK + 프로젝트 상세 (CI 상태 포함)
    FE-->>Developer: 프로젝트 상세 페이지 (CI 상태 카드 표시)
```

---

## 6. 확장 전략

### 6.1 MVP 단계 아키텍처

MVP에서는 단일 Docker Compose 환경으로 운영합니다.

- **동시 사용자 50명** 수용 (MVP 목표)
- **단일 Spring Boot 인스턴스** (Scale-out 불필요)
- **PostgreSQL 단일 인스턴스** (연결 풀: 최소 5, 최대 20)

### 6.2 향후 확장 방향

```mermaid
graph TD
    A[MVP: Single Docker Compose] --> B[Scale-Out 필요 시]
    B --> C[별도 Nginx 서버로 React SPA 분리]
    B --> D[Spring Boot 다중 인스턴스]
    B --> E[Redis 세션 공유]
    B --> F[PostgreSQL Read Replica]

    style A fill:#e1ffe1
    style B fill:#fff4e1
```

- **수평 확장**: Spring Boot를 무상태(Stateless)로 설계하여 향후 다중 인스턴스 가능
- **캐싱**: 외부 API (GitHub, Jenkins, SonarQube) Rate Limit 대응을 위한 캐싱 검토
- **메시지 큐**: CI 설정 생성이 오래 걸리는 경우 비동기 Job Queue 도입 검토

### 6.3 외부 API Rate Limit 대응

| 도구 | Rate Limit | 대응 전략 |
|------|-----------|-----------|
| GitHub App | 15,000 req/시간 | API 응답 캐싱, 불필요한 중복 호출 방지 |
| Jenkins | 서버 정책에 따름 | Timeout 설정 (10초), Circuit Breaker 패턴 검토 |
| SonarQube | 서버 정책에 따름 | Timeout 설정 (15초), 에러 시 명확한 안내 |

---

## 7. 보안 아키텍처

### 7.1 인증 흐름 (Keycloak OIDC)

```mermaid
sequenceDiagram
    actor User
    participant Browser
    participant App as Spring Boot
    participant KC as Keycloak

    User->>Browser: 서비스 접속
    Browser->>App: GET /
    App-->>Browser: React SPA 서빙

    Browser->>App: API 호출 (토큰 없음)
    App-->>Browser: 401 Unauthorized

    Browser->>KC: OIDC Authorization Code Flow
    KC-->>Browser: 로그인 페이지
    User->>KC: 로그인
    KC-->>Browser: Authorization Code
    Browser->>KC: Token 교환
    KC-->>Browser: Access Token + Refresh Token
    Browser->>App: API 호출 (Bearer Token)
    Note over App: Spring Security: JWT 서명 검증 (Keycloak 공개키)
    App-->>Browser: 200 OK + 데이터
```

### 7.2 토큰 암호화 아키텍처 (AES-256-GCM)

```mermaid
graph TD
    A[관리자: CI 도구 토큰 등록] --> B[TokenService]
    B --> C[AES-256-GCM 암호화<br/>마스터 키: 환경 변수]
    C --> D[(PostgreSQL<br/>BYTEA 컬럼에 저장)]

    E[BE: CI 도구 API 호출 필요] --> F[TokenService]
    F --> G[DB에서 암호화된 토큰 조회]
    G --> H[AES-256-GCM 복호화<br/>메모리에서만 사용]
    H --> I[CI 도구 API 호출]
    H --> J[로그 기록 금지<br/>복호화 후 즉시 사용]

    style C fill:#ffe1e1
    style H fill:#ffe1e1
    style J fill:#ffaaaa
```

### 7.3 보안 계층

| 계층 | 보안 조치 |
|------|-----------|
| **전송** | HTTPS (프로덕션 필수), TLS 1.2+ |
| **인증** | Keycloak OIDC, JWT 토큰 검증 (Spring Security) |
| **인가** | RBAC - 서비스 개발자 / 관리자 역할 분리 |
| **데이터** | AES-256-GCM 암호화 (CI 도구 토큰) |
| **입력 검증** | Bean Validation, SQL Injection 방지 (JPA Parameterized Query) |
| **CSRF** | Spring Security CSRF, SameSite 쿠키 |
| **로깅** | 복호화된 토큰 로그 기록 금지, 토큰은 마스킹 처리 |

---

## 8. 운영 및 모니터링

### 8.1 헬스 체크

```
GET /actuator/health
→ { "status": "UP", "components": { "db": { "status": "UP" }, "keycloak": { ... } } }
```

- **응답 시간 목표**: < 200ms
- **Docker Compose**: `healthcheck` 설정으로 자동 재시작
- **의존성 상태**: PostgreSQL 연결 상태 포함

### 8.2 로그 관리

```mermaid
graph LR
    App[Spring Boot] -->|JSON 구조화 로그| Console[콘솔 / 파일]
    Console --> Dev[개발: 콘솔 출력]
    Console --> Prod[운영: 파일 로테이션<br/>일별, 최대 30일]

    style App fill:#e1f5ff
    style Prod fill:#e1ffe1
```

**로그 이벤트**:
- 인증 이벤트 (로그인 성공/실패)
- 프로젝트 생성/삭제
- CI 도구 설정 생성/조회 (성공/실패)
- 토큰 등록/삭제 (토큰 값 제외)
- 외부 API 호출 (요청 시간, 상태 코드, 토큰 마스킹)

---

## ✅ 완료 체크리스트

- [x] 전체 시스템 아키텍처 다이어그램 작성 완료
- [x] C4 Level 1/2 컨텍스트/컨테이너 다이어그램 작성 완료
- [x] 레이어 아키텍처 정의 완료
- [x] 기술 스택 선정 및 문서화 완료 (Kotlin/Spring Boot/React/PostgreSQL/Keycloak)
- [x] Docker Compose 배포 아키텍처 설계 완료
- [x] React SPA Static Serving 방식 정의 완료
- [x] 데이터 흐름 정의 완료 (GitHub Actions 생성, 상태 조회)
- [x] 확장 전략 수립 완료
- [x] 보안 아키텍처 설계 완료 (OIDC, AES-256-GCM)
- [x] 운영/모니터링 전략 정의 완료

---

**다음 단계**: [주요 컴포넌트](components/) 설계
