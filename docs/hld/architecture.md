---
layout: default
title: 시스템 아키텍처
parent: High Level Design
nav_order: 1
---

# 시스템 아키텍처 (System Architecture)
{: .no_toc }

전체 시스템의 구조와 기술 스택을 정의합니다.
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
    title 시스템 컨텍스트 다이어그램

    Person(user, "일반 사용자", "서비스를 이용하는 사용자")
    Person(admin, "관리자", "시스템을 관리하는 사용자")

    System(system, "메인 시스템", "핵심 비즈니스 로직을 처리하는 시스템")

    System_Ext(email, "이메일 서비스", "이메일 발송")
    System_Ext(payment, "결제 시스템", "결제 처리")
    System_Ext(sms, "SMS 서비스", "문자 메시지 발송")

    Rel(user, system, "사용", "HTTPS")
    Rel(admin, system, "관리", "HTTPS")
    Rel(system, email, "이메일 발송", "SMTP/API")
    Rel(system, payment, "결제 요청", "REST API")
    Rel(system, sms, "SMS 발송", "REST API")
```

### 1.2 컨테이너 다이어그램 (C4 Level 2)

```mermaid
graph TB
    subgraph "사용자"
        User[웹 브라우저]
        Mobile[모바일 앱]
    end

    subgraph "DMZ"
        LB[로드 밸런서<br/>Nginx/ALB]
        API_GW[API Gateway]
    end

    subgraph "애플리케이션 레이어"
        Web[웹 서버<br/>React/Next.js]
        API[API 서버<br/>Node.js/Python]
        Worker[백그라운드 워커<br/>Celery/Bull]
    end

    subgraph "데이터 레이어"
        DB[(데이터베이스<br/>PostgreSQL)]
        Cache[(캐시<br/>Redis)]
        Queue[(메시지 큐<br/>RabbitMQ/SQS)]
    end

    subgraph "스토리지"
        S3[오브젝트 스토리지<br/>AWS S3]
    end

    User -->|HTTPS| LB
    Mobile -->|HTTPS| LB
    LB --> Web
    LB --> API_GW
    API_GW --> API
    Web -->|API 호출| API
    API --> DB
    API --> Cache
    API --> Queue
    API --> S3
    Queue --> Worker
    Worker --> DB
    Worker --> Cache

    style User fill:#e1f5ff
    style API fill:#ffe1e1
    style DB fill:#e1ffe1
```

---

## 2. 레이어 아키텍처

### 2.1 레이어 구조

```mermaid
graph TD
    A[Presentation Layer<br/>사용자 인터페이스] --> B[Application Layer<br/>비즈니스 로직]
    B --> C[Domain Layer<br/>도메인 모델]
    C --> D[Infrastructure Layer<br/>데이터 액세스]

    A1[React/Vue Components] -.-> A
    A2[REST API Controllers] -.-> A

    B1[Use Cases] -.-> B
    B2[Services] -.-> B

    C1[Entities] -.-> C
    C2[Value Objects] -.-> C

    D1[Repositories] -.-> D
    D2[External APIs] -.-> D

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#ffe1e1
    style D fill:#e1ffe1
```

### 2.2 레이어별 책임

| 레이어 | 책임 | 기술 스택 |
|--------|------|-----------|
| **Presentation** | UI 렌더링, 사용자 입력 처리 | React, Vue, React Native |
| **Application** | 비즈니스 로직, 트랜잭션 관리 | Express, FastAPI, Django |
| **Domain** | 핵심 비즈니스 규칙, 엔티티 | TypeScript, Python Classes |
| **Infrastructure** | DB 접근, 외부 API 통신 | TypeORM, SQLAlchemy, Prisma |

---

## 3. 기술 스택

### 3.1 전체 기술 스택

```mermaid
graph LR
    subgraph "Frontend"
        F1[React 18+]
        F2[TypeScript]
        F3[Tailwind CSS]
        F4[React Query]
    end

    subgraph "Backend"
        B1[Node.js 18+]
        B2[Express/NestJS]
        B3[TypeScript]
        B4[Prisma ORM]
    end

    subgraph "Database"
        D1[PostgreSQL 14+]
        D2[Redis 7+]
    end

    subgraph "Infrastructure"
        I1[Docker]
        I2[Kubernetes/ECS]
        I3[AWS/Azure]
        I4[Nginx]
    end

    F1 --> B2
    B2 --> D1
    B2 --> D2
    I1 --> I2

    style F1 fill:#e1f5ff
    style B1 fill:#fff4e1
    style D1 fill:#e1ffe1
    style I1 fill:#ffe1f5
```

### 3.2 상세 기술 스택

#### Frontend
| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 프레임워크 | React | 18.x | UI 라이브러리 |
| 언어 | TypeScript | 5.x | 타입 안정성 |
| 상태 관리 | Zustand / Redux Toolkit | - | 전역 상태 |
| 데이터 페칭 | TanStack Query | 5.x | 서버 상태 관리 |
| 스타일링 | Tailwind CSS | 3.x | 유틸리티 CSS |
| 폼 관리 | React Hook Form | 7.x | 폼 밸리데이션 |
| 라우팅 | React Router | 6.x | 클라이언트 라우팅 |

#### Backend
| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 런타임 | Node.js | 18 LTS | 서버 런타임 |
| 프레임워크 | NestJS / Express | 10.x / 4.x | API 서버 |
| 언어 | TypeScript | 5.x | 타입 안정성 |
| ORM | Prisma | 5.x | 데이터베이스 ORM |
| 인증 | Passport.js | 0.7.x | 인증/인가 |
| 밸리데이션 | class-validator | 0.14.x | 입력 검증 |
| API 문서 | Swagger/OpenAPI | 3.0 | API 문서화 |

#### Database & Cache
| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| RDBMS | PostgreSQL | 14+ | 주 데이터베이스 |
| Cache | Redis | 7+ | 세션, 캐싱 |
| 검색 | Elasticsearch | 8.x | 전체 텍스트 검색 (선택) |

#### DevOps & Infrastructure
| 구분 | 기술 | 버전 | 용도 |
|------|------|------|------|
| 컨테이너 | Docker | 24.x | 컨테이너화 |
| 오케스트레이션 | Kubernetes / ECS | - | 컨테이너 관리 |
| CI/CD | GitHub Actions | - | 자동화 |
| 모니터링 | Prometheus + Grafana | - | 메트릭 수집/시각화 |
| 로깅 | ELK Stack | - | 로그 관리 |
| 클라우드 | AWS / Azure | - | 클라우드 인프라 |

---

## 4. 배포 아키텍처

### 4.1 프로덕션 환경

```mermaid
graph TB
    subgraph "Internet"
        Users[사용자]
    end

    subgraph "AWS Cloud"
        subgraph "VPC"
            subgraph "Public Subnet"
                ALB[Application Load Balancer]
                NAT[NAT Gateway]
            end

            subgraph "Private Subnet - App"
                ECS1[ECS Task 1<br/>API Server]
                ECS2[ECS Task 2<br/>API Server]
                ECS3[ECS Task 3<br/>Worker]
            end

            subgraph "Private Subnet - Data"
                RDS[(RDS PostgreSQL<br/>Multi-AZ)]
                ElastiCache[(ElastiCache Redis)]
            end
        end

        S3[S3 Bucket<br/>Static Assets]
        CloudFront[CloudFront CDN]
    end

    Users --> CloudFront
    CloudFront --> ALB
    CloudFront --> S3
    ALB --> ECS1
    ALB --> ECS2
    ECS1 --> RDS
    ECS2 --> RDS
    ECS3 --> RDS
    ECS1 --> ElastiCache
    ECS2 --> ElastiCache
    ECS3 --> NAT
    NAT --> Internet

    style Users fill:#e1f5ff
    style ALB fill:#fff4e1
    style RDS fill:#e1ffe1
```

### 4.2 환경별 구성

| 환경 | 용도 | 인스턴스 | Auto Scaling |
|------|------|----------|--------------|
| **Development** | 개발 | t3.small x 1 | 없음 |
| **Staging** | QA/테스트 | t3.medium x 2 | 2-4 |
| **Production** | 운영 | t3.large x 2 | 2-10 |

---

## 5. 데이터 흐름

### 5.1 읽기 흐름

```mermaid
sequenceDiagram
    actor User
    participant CDN as CloudFront
    participant LB as Load Balancer
    participant API as API Server
    participant Cache as Redis
    participant DB as PostgreSQL

    User->>CDN: GET /api/items
    CDN->>LB: Cache Miss
    LB->>API: 요청 전달
    API->>Cache: 캐시 확인
    alt 캐시 있음
        Cache-->>API: 캐시된 데이터
    else 캐시 없음
        API->>DB: SELECT query
        DB-->>API: 데이터 반환
        API->>Cache: 캐시 저장 (TTL: 5분)
    end
    API-->>LB: 200 OK + 데이터
    LB-->>CDN: 응답 전달
    CDN-->>User: 응답 (캐시 저장)
```

### 5.2 쓰기 흐름

```mermaid
sequenceDiagram
    actor User
    participant API as API Server
    participant Queue as Message Queue
    participant Worker as Background Worker
    participant DB as PostgreSQL
    participant Cache as Redis
    participant Notify as Notification Service

    User->>API: POST /api/items
    API->>API: 입력 검증
    API->>DB: BEGIN TRANSACTION
    API->>DB: INSERT data
    API->>Queue: 발행 (item.created 이벤트)
    API->>DB: COMMIT
    API->>Cache: 캐시 무효화
    API-->>User: 201 Created

    Queue->>Worker: 이벤트 수신
    Worker->>Notify: 알림 발송
    Worker->>DB: 통계 업데이트
```

---

## 6. 확장 전략

### 6.1 수평 확장 (Horizontal Scaling)

**애플리케이션 서버**
- Auto Scaling Group 사용
- 메트릭 기반 자동 확장:
  - CPU 사용률 > 70%: Scale Out
  - CPU 사용률 < 30%: Scale In
- 무상태(Stateless) 설계로 인스턴스 추가/제거 자유로움

**데이터베이스**
- Read Replica를 통한 읽기 부하 분산
- Connection Pooling (최소 10, 최대 100)
- 샤딩 전략 (100만 사용자 이상 시)

### 6.2 캐싱 전략

**레벨별 캐싱**

```mermaid
graph TD
    A[브라우저 캐시] --> B[CDN 캐시]
    B --> C[API Gateway 캐시]
    C --> D[Redis 캐시]
    D --> E[Database Query Cache]
    E --> F[데이터베이스]

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#ffe1e1
    style D fill:#e1ffe1
    style E fill:#f5e1ff
```

| 레벨 | TTL | 대상 |
|------|-----|------|
| **CDN** | 24시간 | 정적 파일 (JS, CSS, 이미지) |
| **Redis** | 5분 | API 응답 (자주 조회되는 데이터) |
| **DB Query** | 1분 | 집계 쿼리 결과 |

---

## 7. 보안 아키텍처

### 7.1 네트워크 보안

```mermaid
graph TB
    subgraph "Internet"
        User[사용자]
    end

    subgraph "Security Layer"
        WAF[AWS WAF<br/>DDoS 방어]
        CloudFront[CloudFront<br/>SSL/TLS]
    end

    subgraph "VPC - Public"
        ALB[Load Balancer<br/>SSL 종료]
    end

    subgraph "VPC - Private"
        API[API Servers<br/>Security Groups]
        DB[(Database<br/>Private Subnet)]
    end

    User --> WAF
    WAF --> CloudFront
    CloudFront --> ALB
    ALB --> API
    API --> DB

    style WAF fill:#ffe1e1
    style API fill:#fff4e1
    style DB fill:#e1ffe1
```

### 7.2 보안 계층

| 계층 | 보안 조치 |
|------|-----------|
| **네트워크** | VPC 격리, Security Groups, NACLs |
| **애플리케이션** | JWT 인증, CORS, Rate Limiting |
| **데이터** | 암호화 (전송: TLS 1.3, 저장: AES-256) |
| **모니터링** | 침입 탐지, 로그 분석, 알림 |

---

## 8. 재해 복구 (DR)

### 8.1 백업 전략

| 데이터 | 백업 주기 | 보관 기간 | RPO |
|--------|-----------|-----------|-----|
| **데이터베이스** | 매시간 (증분), 매일 (전체) | 30일 | 5분 |
| **파일 스토리지** | 매일 | 90일 | 24시간 |
| **설정 파일** | Git 버전 관리 | 영구 | 실시간 |

### 8.2 장애 복구 절차

1. **장애 감지**: 모니터링 시스템 (Prometheus, CloudWatch)
2. **알림 발송**: PagerDuty, Slack, SMS
3. **자동 복구**: Health Check 실패 시 인스턴스 재시작
4. **수동 개입**: 30분 내 복구 불가 시 DR 사이트 활성화

---

## ✅ 완료 체크리스트

- [ ] 전체 시스템 아키텍처 다이어그램 작성 완료
- [ ] 레이어 아키텍처 정의 완료
- [ ] 기술 스택 선정 및 문서화 완료
- [ ] 배포 아키텍처 설계 완료
- [ ] 데이터 흐름 정의 완료
- [ ] 확장 전략 수립 완료
- [ ] 보안 아키텍처 설계 완료
- [ ] DR 전략 수립 완료
- [ ] 아키텍처 리뷰 완료

---

**다음 단계**: [주요 컴포넌트](components/) 설계
