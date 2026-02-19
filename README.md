# AI 설계 문서 템플릿

AI를 활용한 체계적인 소프트웨어 설계 문서 관리 템플릿입니다.

## 🎯 특징

- ✅ **체계적인 설계 흐름**: 요구사항 → HLD → DLD → 테스트 전략
- 🤖 **AI 프롬프트 템플릿**: 각 단계별 상세 가이드 제공
- 📊 **Mermaid 다이어그램**: 코드 기반 다이어그램 작성
- 🚀 **GitHub Pages 자동 배포**: 문서를 웹사이트로 자동 게시
- 🔍 **검색 기능**: just-the-docs 테마의 강력한 문서 검색

## 🚀 빠른 시작

### 1. 템플릿 사용하기

**방법 A: GitHub에서 "Use this template" 버튼 클릭**
```bash
# GitHub에서 이 레포지토리를 템플릿으로 사용하여 새 레포지토리 생성
```

**방법 B: Clone**
```bash
git clone https://github.com/your-username/design-document-by-ai-template.git
cd design-document-by-ai-template
```

### 2. 로컬에서 문서 보기

#### 방법 A: Docker 사용 (권장) 🐳

**Windows (PowerShell):**
```powershell
.\run-docs.ps1 start
```

**macOS / Linux:**
```bash
./run-docs.sh start
```

**사용 가능한 명령어:**
- `start` - 서버 시작
- `stop` - 서버 중지
- `restart` - 서버 재시작
- `logs` - 로그 보기
- `build` - 이미지 다시 빌드
- `clean` - 컨테이너/볼륨 삭제
- `status` - 상태 확인

#### 방법 B: 로컬 Ruby 환경

```bash
cd docs
bundle install
bundle exec jekyll serve

# 브라우저에서 http://localhost:4000 접속
```

### 3. AI로 설계 문서 작성

`templates/` 디렉토리의 프롬프트 템플릿을 사용하세요:

1. **요구사항 분석**: `templates/00-requirements-prompt.md`
2. **HLD 작성**: `templates/01-hld-prompt.md`
3. **DLD 작성**: `templates/02-dld-prompt.md`
4. **테스트 전략**: `templates/03-test-strategy-prompt.md`

AI (Claude, ChatGPT 등)에게 프롬프트를 전달하고, 생성된 내용을 `docs/` 디렉토리의 해당 파일에 작성하세요.

### 4. GitHub Pages 배포

#### 설정 방법

1. GitHub 레포지토리 Settings → Pages
2. Source: **GitHub Actions** 선택
3. `main` 브랜치에 push하면 자동 배포

#### 배포 확인

- 배포 URL: `https://your-username.github.io/your-repo/`
- Actions 탭에서 배포 상태 확인

## 📁 프로젝트 구조

```
design-document-by-ai-template/
├── docs/                          # 설계 문서
│   ├── requirements/              # 요구사항
│   ├── hld/                       # High Level Design
│   ├── dld/                       # Detailed Level Design
│   └── test-strategy/             # 테스트 전략
├── templates/                     # AI 프롬프트 템플릿
│   ├── 00-requirements-prompt.md
│   ├── 01-hld-prompt.md
│   ├── 02-dld-prompt.md
│   └── 03-test-strategy-prompt.md
├── .github/workflows/             # GitHub Actions
│   ├── deploy-pages.yml           # GitHub Pages 배포
│   └── llm-agent.yml              # LLM Agent 자동화
└── README.md
```

## 📝 문서 작성 가이드

### 설계 단계별 작성 순서

1. **요구사항 분석** (`docs/requirements/`)
   - 프로젝트 목표와 기능 정의
   - 기능/비기능 요구사항 작성
   - 제약사항 파악

2. **High Level Design** (`docs/hld/`)
   - 전체 시스템 아키텍처 설계
   - 주요 컴포넌트 식별
   - 기술 스택 선정

3. **Detailed Level Design** (`docs/dld/`)
   - API 명세 작성
   - 데이터 모델 (ERD) 설계
   - 클래스 및 모듈 구조 정의

4. **테스트 전략** (`docs/test-strategy/`)
   - 테스트 계획 수립
   - 테스트 케이스 작성
   - 품질 메트릭 정의

### Mermaid 다이어그램 예시

```markdown
\`\`\`mermaid
graph TD
    A[요구사항] --> B[HLD]
    B --> C[DLD]
    C --> D[구현]
\`\`\`
```

## 🤖 AI 활용 팁

### 효과적인 프롬프트 작성

1. **구체적으로**: "사용자 인증 기능" 보다 "이메일/비밀번호 기반 JWT 인증"
2. **제약사항 명시**: "Node.js 사용", "PostgreSQL 필수"
3. **예시 제공**: 원하는 형식이나 스타일 예시 포함
4. **반복 개선**: 한 번에 완벽하게 하려 하지 말고 점진적으로 개선

### 추천 AI 도구

- **Claude** (Anthropic): 긴 문서 작성, 코드 생성
- **ChatGPT** (OpenAI): 다양한 설계 아이디어
- **GitHub Copilot**: 코드 기반 제안

## 🤖 GitHub Issue 기반 LLM Agent 자동화

GitHub Issue에 특정 Label을 달면 자동으로 LLM Agent가 실행되어 결과를 Comment로 작성합니다.

### Label 형식

- **Claude**: `claude:<model-id>` (예: `claude:claude-sonnet-4`, `claude:claude-opus-4`)
- **Gemini**: `gemini:<model-id>` (예: `gemini:gemini-pro`, `gemini:gemini-flash`)

Label의 모델 ID가 그대로 API에 전달됩니다.

### 사용 가능한 모델

#### Claude Models
| Label | 설명 |
|-------|------|
| `claude:claude-sonnet-4` | 균형잡힌 성능과 속도 (권장, 최신 버전) |
| `claude:claude-opus-4` | 최고 성능, 복잡한 작업 (최신 버전) |
| `claude:claude-haiku-4` | 빠른 응답, 간단한 작업 (최신 버전) |
| `claude:claude-3-5-sonnet` | Claude 3.5 Sonnet (최신 버전) |
| `claude:claude-3-opus` | Claude 3 Opus (최신 버전) |
| `claude:claude-3-haiku` | Claude 3 Haiku (최신 버전) |

**특정 날짜 버전 지정:**
- `claude:claude-sonnet-4-20250514`
- `claude:claude-3-5-sonnet-20241022`

전체 모델 목록: [Anthropic Models](https://docs.anthropic.com/en/docs/about-claude/models)

#### Gemini Models
| Label | 설명 |
|-------|------|
| `gemini:gemini-pro` | 범용 모델 (권장) |
| `gemini:gemini-flash` | 빠른 응답 |
| `gemini:gemini-2.0-flash-exp` | 실험적 최신 모델 |
| `gemini:gemini-1.5-pro` | 긴 컨텍스트 지원 |
| `gemini:gemini-1.5-flash` | 빠른 응답 (1.5 세대) |

전체 모델 목록: [Google AI Models](https://ai.google.dev/models/gemini)

### 설정 방법

#### 1. Repository Secrets 설정

GitHub 레포지토리 **Settings → Secrets and variables → Actions → New repository secret**에서 다음 시크릿을 추가하세요:

**Claude 사용 시:**
- Secret name: `ANTHROPIC_API_KEY`
- Secret value: Anthropic API Key ([여기서 발급](https://console.anthropic.com/settings/keys))
- 참고: Anthropic API를 직접 사용합니다

**Gemini 사용 시:**
- Secret name: `GOOGLE_API_KEY`
- Secret value: Google AI Studio API Key ([여기서 발급](https://aistudio.google.com/app/apikey))

#### 2. GitHub Labels 생성

레포지토리 **Issues → Labels**에서 자주 사용할 Label을 미리 생성하세요:

**Claude Labels (색상: #7C3AED 추천):**
- `claude:claude-sonnet-4`
- `claude:claude-opus-4`
- `claude:claude-haiku-4`

**Gemini Labels (색상: #4285F4 추천):**
- `gemini:gemini-pro`
- `gemini:gemini-flash`
- `gemini:gemini-2.0-flash-exp`

필요한 Label만 선택적으로 생성하면 됩니다.

### 사용 방법

1. **Issue 생성**: 분석하고 싶은 내용을 Issue Description에 작성
2. **Label 추가**: 원하는 모델의 Label 추가 (예: `claude:sonnet-4`, `gemini:pro`)
3. **자동 실행**: GitHub Actions가 자동으로 LLM을 실행
4. **결과 확인**: Issue Comment에 LLM 응답이 자동으로 작성됨

### 예시

#### 예시 1: Claude Sonnet 사용
```markdown
### Issue Title
요구사항 분석: 온라인 도서 대여 시스템

### Issue Description
다음 프로젝트의 요구사항을 분석해주세요:

- 프로젝트명: 도서 대여 플랫폼
- 목적: 온라인 도서 검색 및 대여
- 대상 사용자: 일반 독서가, 학생
- 핵심 기능:
  1. 도서 검색 및 필터링
  2. 도서 대여 및 반납
  3. 사용자 리뷰 작성

기능 요구사항과 비기능 요구사항을 작성해주세요.
```

**Label 추가**: `claude:claude-sonnet-4`

#### 예시 2: Gemini Pro 사용
```markdown
### Issue Title
성능 최적화 방안 분석

### Issue Description
현재 시스템의 병목 구간을 분석하고 최적화 방안을 제시해주세요.

- 현재 응답 시간: 500ms
- 목표: 200ms 이하
- 주요 트래픽: API 호출 10,000 req/s
```

**Label 추가**: `gemini:gemini-pro`

#### 예시 3: 빠른 응답이 필요한 경우
```markdown
### Issue Title
간단한 질문

### Issue Description
이 에러 메시지가 무엇을 의미하나요?
```

**Label 추가**: `claude:claude-haiku-4` 또는 `gemini:gemini-flash`

### 보안 및 제한사항

#### 접근 제어
- **Repository 오너만 실행 가능**: Issue 작성자가 Repository 오너인 경우에만 workflow 실행
- **Concurrency 제한**: Repository당 한 번에 하나의 LLM Agent만 실행 (순차 처리)

#### 사용 제한
- **Issue body 길이 제한**: 최대 50,000자 (API 비용 남용 방지)
- **응답 길이 제한**: 최대 60,000자 (GitHub Comment 크기 제한)
- **실행 시간 제한**: 최대 10분 (timeout 설정)
- **동시 실행**: GitHub Actions 기본 제한 적용

#### 주의사항
- API 사용량에 따라 비용이 발생할 수 있습니다
- 공개 레포지토리에서는 누구나 Label을 추가할 수 있으나, Repository 오너만 실행됩니다
- 잘못된 모델명을 사용하면 에러가 발생합니다 (Issue Comment에 에러 메시지 표시됨)

#### 추가 보안 권장사항
1. **Private Repository 사용**: API 키 남용 방지
2. **Issue Template 사용**: 구조화된 입력으로 프롬프트 인젝션 방지
3. **Label 권한 제한**: Repository Settings에서 Label 추가 권한 제한
4. **API 사용량 모니터링**: Anthropic/Google Cloud 콘솔에서 사용량 확인

## 🛠️ 커스터마이징

### _config.yml 수정 (중요!)

**GitHub Pages 배포 전 필수 설정:**

```yaml
# docs/_config.yml
title: 프로젝트 이름
description: 프로젝트 설명

# GitHub Pages URL 설정 (레포지토리 이름과 일치해야 함!)
baseurl: "/your-repo-name"  # ⚠️ 실제 레포지토리 이름으로 변경
url: "https://your-username.github.io"  # ⚠️ 실제 GitHub username으로 변경

# GitHub 링크 설정
aux_links:
  "GitHub에서 보기":
    - "//github.com/your-username/your-repo"

gh_edit_repository: "https://github.com/your-username/your-repo"
```

**로컬 개발 시:**
- `_config_dev.yml`이 자동으로 적용되어 `baseurl` 없이 작동합니다
- Docker 또는 `bundle exec jekyll serve` 모두 지원

### 색상 테마 변경

```yaml
# docs/_config.yml
color_scheme: light  # 또는 dark
```

## 📚 참고 자료

- [Jekyll 문서](https://jekyllrb.com/docs/)
- [just-the-docs 테마](https://just-the-docs.com/)
- [Mermaid 다이어그램](https://mermaid.js.org/)
- [GitHub Pages](https://pages.github.com/)

## 🤝 기여

이슈 리포트, 기능 제안, 풀 리퀘스트를 환영합니다!

## 📄 라이선스

MIT License - 자유롭게 사용하세요.

---

**Happy Documenting with AI! 🚀**
