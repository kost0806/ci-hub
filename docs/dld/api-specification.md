---
layout: default
title: API 명세
parent: Detailed Level Design
nav_order: 1
---

# API 명세 (API Specification)
{: .no_toc }

RESTful API의 상세 명세를 작성합니다.
{: .fs-6 .fw-300 }

---

## 목차
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 1. API 개요

<!-- API의 기본 정보를 작성하세요 -->

- **Base URL**: `https://api.example.com/v1`
- **인증 방식**: Bearer Token (JWT)
- **Content-Type**: `application/json`

---

## 2. 인증 API

### POST /auth/login

**요청:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**응답 (200 OK):**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 3600
}
```

**에러 응답:**
- `400 Bad Request`: 유효하지 않은 입력
- `401 Unauthorized`: 인증 실패
- `500 Internal Server Error`: 서버 오류

---

## 3. [도메인] API

<!-- 추가 API 엔드포인트를 작성하세요 -->

### GET /items

**Query Parameters:**
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| page | number | ❌ | 페이지 번호 (기본: 1) |
| limit | number | ❌ | 페이지 크기 (기본: 20) |
| search | string | ❌ | 검색 키워드 |

**응답 (200 OK):**
```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "limit": 20
}
```

---

## 4. 에러 코드

| 코드 | 설명 | 해결 방법 |
|------|------|-----------|
| E001 | 인증 토큰 만료 | 리프레시 토큰으로 갱신 |
| E002 | 권한 없음 | 관리자 문의 |

---

## ✅ 완료 체크리스트

- [ ] 모든 엔드포인트 문서화 완료
- [ ] 요청/응답 예시 작성 완료
- [ ] 에러 코드 정의 완료
