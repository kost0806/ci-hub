---
layout: default
title: 홈
nav_order: 1
description: "AI 기반 소프트웨어 설계 문서 관리 템플릿"
permalink: /
---

# AI 설계 문서 템플릿
{: .fs-9 }

AI를 활용한 체계적인 소프트웨어 설계 문서 작성 및 관리 템플릿입니다.
{: .fs-6 .fw-300 }

[시작하기](#프로젝트-개요){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[GitHub에서 보기](https://github.com/your-username/your-repo){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 프로젝트 개요

이 템플릿은 소프트웨어 프로젝트의 설계 단계를 체계적으로 문서화하고, AI를 활용하여 효율적으로 작성할 수 있도록 지원합니다.

### 📋 설계 흐름

```mermaid
graph LR
    A[요구사항 분석] --> B[High Level Design]
    B --> C[Detailed Level Design]
    C --> D[테스트 전략]
    D --> E[구현]

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#ffe1f5
    style D fill:#e1ffe1
    style E fill:#f5e1ff
```

### 🎯 주요 특징

- **체계적인 문서 구조**: 요구사항 → HLD → DLD → 테스트 전략
- **AI 프롬프트 템플릿**: 각 설계 단계별 상세 가이드 제공
- **Mermaid 다이어그램**: 코드 기반 다이어그램 작성
- **GitHub Pages 자동 배포**: 문서를 웹사이트로 자동 게시
- **검색 기능**: just-the-docs 테마의 강력한 검색 지원

---

## 📚 문서 구조

### 1. [요구사항 (Requirements)](requirements/)
프로젝트의 기능 및 비기능 요구사항을 정의합니다.
- 기능 요구사항
- 비기능 요구사항 (성능, 보안, 확장성)
- 제약사항 및 가정

### 2. [High Level Design (HLD)](hld/)
시스템의 전체 아키텍처와 주요 컴포넌트를 설계합니다.
- 시스템 아키텍처
- 주요 컴포넌트
- 인터페이스 설계

### 3. [Detailed Level Design (DLD)](dld/)
각 컴포넌트의 상세 구현 사항을 설계합니다.
- API 명세
- 데이터 모델
- 클래스/모듈 설계
- 구현 상세

### 4. [테스트 전략 (Test Strategy)](test-strategy/)
품질 보증을 위한 테스트 계획을 수립합니다.
- 테스트 계획
- 테스트 케이스
- 품질 메트릭

---

## 🚀 빠른 시작

### 1. 템플릿 사용하기
```bash
# 이 레포지토리를 템플릿으로 사용하여 새 프로젝트 생성
# GitHub에서 "Use this template" 버튼 클릭

# 또는 클론
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 2. AI 프롬프트 활용
`templates/` 디렉토리에서 각 설계 단계별 AI 프롬프트를 확인하고 활용하세요.

```bash
templates/
├── 00-requirements-prompt.md     # 요구사항 작성 가이드
├── 01-hld-prompt.md              # HLD 작성 가이드
├── 02-dld-prompt.md              # DLD 작성 가이드
└── 03-test-strategy-prompt.md    # 테스트 전략 가이드
```

### 3. 로컬에서 문서 보기
```bash
cd docs
bundle install
bundle exec jekyll serve

# 브라우저에서 http://localhost:4000 접속
```

---

## 🤖 AI 활용 가이드

### AI에게 설계 요청하기

1. **요구사항 단계**
   - `templates/00-requirements-prompt.md`의 프롬프트를 AI에게 전달
   - AI가 생성한 내용을 `docs/requirements/` 파일들에 작성

2. **HLD 단계**
   - 요구사항을 바탕으로 `templates/01-hld-prompt.md` 활용
   - Mermaid 다이어그램과 함께 아키텍처 설계

3. **DLD 단계**
   - HLD를 기반으로 `templates/02-dld-prompt.md` 활용
   - API 명세, 데이터 모델 등 상세 설계

4. **테스트 전략**
   - 전체 설계를 바탕으로 `templates/03-test-strategy-prompt.md` 활용
   - 테스트 케이스 및 품질 메트릭 정의

---

## 📊 진행 상황 추적

### 설계 단계별 체크리스트

- [ ] 요구사항 분석 완료
  - [ ] 기능 요구사항 정의
  - [ ] 비기능 요구사항 정의
  - [ ] 제약사항 문서화
- [ ] HLD 작성 완료
  - [ ] 시스템 아키텍처 다이어그램
  - [ ] 주요 컴포넌트 정의
  - [ ] 인터페이스 설계
- [ ] DLD 작성 완료
  - [ ] API 명세
  - [ ] 데이터 모델 (ERD)
  - [ ] 클래스/모듈 설계
  - [ ] 구현 상세
- [ ] 테스트 전략 수립 완료
  - [ ] 테스트 계획
  - [ ] 테스트 케이스 작성
  - [ ] 품질 메트릭 정의

---

## 📖 추가 리소스

- [Jekyll 문서](https://jekyllrb.com/docs/)
- [just-the-docs 테마](https://just-the-docs.com/)
- [Mermaid 다이어그램](https://mermaid.js.org/)
- [GitHub Pages](https://pages.github.com/)

---

## 🤝 기여하기

이슈 리포트, 기능 제안, 풀 리퀘스트를 환영합니다!

## 📄 라이선스

MIT License - 자유롭게 사용하세요.
