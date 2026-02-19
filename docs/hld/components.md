---
layout: default
title: 주요 컴포넌트
parent: High Level Design
nav_order: 2
---

# 주요 컴포넌트 (Components)
{: .no_toc }

시스템을 구성하는 주요 컴포넌트와 역할을 정의합니다.
{: .fs-6 .fw-300 }

---

## 목차
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. 컴포넌트 개요

```mermaid
graph TB
    subgraph "Frontend Components"
        UI[UI Components]
        State[State Management]
        Router[Router]
    end

    subgraph "Backend Components"
        Auth[Authentication]
        API[API Gateway]
        Service[Business Services]
        Repository[Data Repository]
    end

    subgraph "Infrastructure Components"
        Queue[Message Queue]
        Cache[Cache Service]
        Storage[File Storage]
    end

    UI --> API
    State --> UI
    Router --> UI
    API --> Auth
    API --> Service
    Service --> Repository
    Service --> Queue
    Service --> Cache
    Service --> Storage

    style UI fill:#e1f5ff
    style Service fill:#fff4e1
    style Repository fill:#e1ffe1
```

---

## 2. Frontend 컴포넌트

### 2.1 UI Components

**책임**: 사용자 인터페이스 렌더링 및 사용자 입력 처리

**주요 모듈**:
- `components/common/`: 공통 UI 컴포넌트 (Button, Input, Modal)
- `components/features/`: 기능별 컴포넌트 (UserProfile, Dashboard)
- `components/layouts/`: 레이아웃 컴포넌트 (Header, Sidebar, Footer)

**기술**: React, TypeScript, Tailwind CSS

### 2.2 State Management

**책임**: 애플리케이션 전역 상태 관리

**상태 분류**:
- **UI State**: 모달, 토스트, 로딩 상태
- **Server State**: API로부터 가져온 데이터 (TanStack Query)
- **User State**: 사용자 정보, 인증 상태

**기술**: Zustand (전역 상태), TanStack Query (서버 상태)

### 2.3 Routing

**책임**: 클라이언트 사이드 라우팅

**라우트 구조**:
```
/               → 홈
/login          → 로그인
/dashboard      → 대시보드 (인증 필요)
/items          → 아이템 목록
/items/:id      → 아이템 상세
/admin          → 관리자 (권한 필요)
```

**기술**: React Router v6

---

## 3. Backend 컴포넌트

### 3.1 Authentication Component

**책임**: 사용자 인증 및 인가

```mermaid
sequenceDiagram
    participant Client
    participant AuthController
    participant AuthService
    participant TokenService
    participant UserRepository
    participant DB

    Client->>AuthController: POST /auth/login
    AuthController->>AuthService: login(email, password)
    AuthService->>UserRepository: findByEmail(email)
    UserRepository->>DB: SELECT
    DB-->>UserRepository: User data
    UserRepository-->>AuthService: User
    AuthService->>AuthService: verifyPassword
    AuthService->>TokenService: generateTokens(userId)
    TokenService-->>AuthService: {accessToken, refreshToken}
    AuthService-->>AuthController: Tokens
    AuthController-->>Client: 200 OK + Tokens
```

**API 엔드포인트**:
- `POST /auth/register`: 회원가입
- `POST /auth/login`: 로그인
- `POST /auth/logout`: 로그아웃
- `POST /auth/refresh`: 토큰 갱신
- `POST /auth/forgot-password`: 비밀번호 재설정 요청

**의존성**: UserRepository, TokenService, EmailService

### 3.2 API Gateway

**책임**: 요청 라우팅, 인증 검증, Rate Limiting

**기능**:
- Request Validation (입력 검증)
- Authentication (JWT 토큰 검증)
- Rate Limiting (API 호출 제한)
- Request Logging (요청 로깅)
- Error Handling (에러 처리)

**미들웨어 체인**:
```
요청 → Logger → Rate Limiter → Authenticator → Validator → Controller → 응답
```

### 3.3 Business Services

**책임**: 비즈니스 로직 처리

#### UserService
- 사용자 CRUD 작업
- 프로필 관리
- 권한 관리

#### ItemService
- 아이템 생성/조회/수정/삭제
- 검색 및 필터링
- 페이지네이션

#### NotificationService
- 알림 생성 및 발송
- 이메일/푸시 알림
- 알림 설정 관리

**패턴**: Service Layer Pattern, Dependency Injection

### 3.4 Data Repository

**책임**: 데이터 접근 추상화

```mermaid
classDiagram
    class IRepository {
        <<interface>>
        +findById(id)
        +findAll(filter)
        +create(data)
        +update(id, data)
        +delete(id)
    }

    class UserRepository {
        +findByEmail(email)
        +findByUsername(username)
    }

    class ItemRepository {
        +findByCategory(category)
        +search(query)
    }

    IRepository <|-- UserRepository
    IRepository <|-- ItemRepository
```

**기술**: Prisma ORM, Repository Pattern

---

## 4. Infrastructure 컴포넌트

### 4.1 Message Queue Component

**책임**: 비동기 작업 큐 관리

**큐 타입**:
- `email-queue`: 이메일 발송
- `notification-queue`: 푸시 알림
- `analytics-queue`: 분석 데이터 처리
- `report-queue`: 리포트 생성

**워커 구조**:
```mermaid
graph LR
    Producer[API Server] -->|메시지 발행| Queue[(Message Queue)]
    Queue -->|메시지 소비| Worker1[Worker 1]
    Queue -->|메시지 소비| Worker2[Worker 2]
    Queue -->|메시지 소비| Worker3[Worker 3]

    Worker1 --> Result[처리 결과]
    Worker2 --> Result
    Worker3 --> Result

    style Queue fill:#fff4e1
    style Worker1 fill:#e1ffe1
```

**기술**: Bull (Redis 기반), RabbitMQ

### 4.2 Cache Service

**책임**: 데이터 캐싱 및 세션 관리

**캐시 전략**:

| 전략 | 적용 대상 | TTL |
|------|-----------|-----|
| **Cache Aside** | API 응답 | 5분 |
| **Write Through** | 사용자 프로필 | 30분 |
| **Write Behind** | 통계 데이터 | 1시간 |

**캐시 키 네이밍**:
```
user:{userId}              → 사용자 정보
item:list:{page}:{filter}  → 아이템 목록
session:{sessionId}        → 세션 데이터
```

**기술**: Redis, Cache-Manager

### 4.3 File Storage Component

**책임**: 파일 업로드/다운로드 관리

**지원 파일 타입**:
- 이미지: JPG, PNG, WebP (최대 10MB)
- 문서: PDF, DOCX (최대 20MB)
- 비디오: MP4 (최대 100MB)

**처리 플로우**:
```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Storage
    participant CDN

    Client->>API: POST /upload (multipart)
    API->>API: 파일 검증 (타입, 크기)
    API->>Storage: 업로드 (S3)
    Storage-->>API: 파일 URL
    API->>CDN: 캐시 무효화
    API-->>Client: 200 OK + URL
```

**기술**: AWS S3, CloudFront

---

## 5. 컴포넌트 간 통신

### 5.1 동기 통신

**프로토콜**: HTTP/HTTPS, REST API

**통신 패턴**:
- Frontend ↔ API Gateway: REST API
- API Gateway ↔ Services: Function Call
- Services ↔ Repository: Function Call

### 5.2 비동기 통신

**프로토콜**: Message Queue (AMQP, Redis Pub/Sub)

**통신 패턴**:
- Services → Message Queue: 이벤트 발행
- Workers ← Message Queue: 이벤트 구독

**이벤트 타입**:
```typescript
// 이벤트 정의
interface UserCreatedEvent {
  type: 'user.created';
  userId: string;
  email: string;
  timestamp: Date;
}

interface ItemPurchasedEvent {
  type: 'item.purchased';
  itemId: string;
  userId: string;
  amount: number;
  timestamp: Date;
}
```

---

## 6. 컴포넌트 의존성

```mermaid
graph TD
    UI[UI Components]
    State[State Management]
    API[API Gateway]
    Auth[Auth Service]
    User[User Service]
    Item[Item Service]
    Notify[Notification Service]
    UserRepo[User Repository]
    ItemRepo[Item Repository]
    Cache[Cache Service]
    Queue[Message Queue]
    DB[(Database)]

    UI --> State
    UI --> API
    API --> Auth
    API --> User
    API --> Item
    Auth --> UserRepo
    User --> UserRepo
    User --> Notify
    Item --> ItemRepo
    Item --> Cache
    Notify --> Queue
    UserRepo --> DB
    ItemRepo --> DB
    Queue --> Notify

    style UI fill:#e1f5ff
    style API fill:#fff4e1
    style DB fill:#e1ffe1
```

---

## 7. 컴포넌트 생명주기

### 7.1 초기화 순서

```
1. Configuration 로드
2. Database 연결
3. Redis 연결
4. Message Queue 연결
5. 미들웨어 초기화
6. 라우트 등록
7. 서버 시작
8. Health Check 활성화
```

### 7.2 종료 순서

```
1. Health Check 비활성화 (새 요청 거부)
2. 진행 중인 요청 완료 대기 (최대 30초)
3. Message Queue 연결 종료
4. Database 연결 종료
5. Redis 연결 종료
6. 로그 플러시
7. 프로세스 종료
```

---

## 8. 컴포넌트 설정

### 8.1 환경 변수

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=1h

# S3
AWS_S3_BUCKET=your-bucket
AWS_REGION=ap-northeast-2

# Message Queue
RABBITMQ_URL=amqp://localhost:5672
```

### 8.2 컴포넌트별 설정

각 컴포넌트는 `config/` 디렉토리에 설정 파일 보유:
- `config/database.ts`
- `config/redis.ts`
- `config/auth.ts`
- `config/storage.ts`

---

## ✅ 완료 체크리스트

- [ ] Frontend 컴포넌트 정의 완료
- [ ] Backend 컴포넌트 정의 완료
- [ ] Infrastructure 컴포넌트 정의 완료
- [ ] 컴포넌트 간 통신 방식 정의 완료
- [ ] 컴포넌트 의존성 매핑 완료
- [ ] 컴포넌트 생명주기 정의 완료

---

**다음 단계**: [인터페이스 설계](interface-design/)
