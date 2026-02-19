# AI 프롬프트 템플릿 사용 가이드

이 디렉토리에는 AI를 활용하여 설계 문서를 작성할 때 사용할 수 있는 프롬프트 템플릿이 포함되어 있습니다.

## 📋 템플릿 목록

0. **[INITIALIZATION.md](../INITIALIZATION.md)** - 프로젝트 초기화 (Agent에게 프로젝트 컨텍스트 전달)
1. **00-requirements-prompt.md** - 요구사항 분석 프롬프트
2. **01-hld-prompt.md** - High Level Design 프롬프트
3. **02-dld-prompt.md** - Detailed Level Design 프롬프트
4. **03-test-strategy-prompt.md** - 테스트 전략 프롬프트

## 🚀 사용 방법

### 0단계: 프로젝트 초기화
[INITIALIZATION.md](../INITIALIZATION.md) 템플릿을 작성하여 AI Agent에게 프로젝트 전체 맥락을 전달하세요.

### 1단계: 프로젝트 정보 준비
프롬프트를 사용하기 전에 다음 정보를 준비하세요:
- 프로젝트 개요 및 목적
- 주요 기능 리스트
- 기술적 제약사항
- 예산 및 일정

### 2단계: 템플릿 선택
설계 단계에 맞는 템플릿을 선택합니다:
- 요구사항 분석 → `00-requirements-prompt.md`
- 아키텍처 설계 → `01-hld-prompt.md`
- 상세 설계 → `02-dld-prompt.md`
- 테스트 계획 → `03-test-strategy-prompt.md`

### 3단계: 프롬프트 커스터마이징
템플릿의 `[대괄호]` 부분을 프로젝트에 맞게 수정합니다.

### 4단계: AI에게 전달
완성된 프롬프트를 AI (Claude, ChatGPT 등)에게 전달합니다.

### 5단계: 결과 검토 및 문서화
AI가 생성한 내용을 검토하고 `docs/` 디렉토리의 해당 문서에 작성합니다.

## 💡 팁

- **반복적 개선**: 한 번에 완벽한 결과를 기대하지 말고, AI와 대화하며 점진적으로 개선하세요.
- **구체적인 질문**: 애매한 부분은 AI에게 구체적인 질문을 하세요.
- **예시 제공**: 원하는 형식이나 스타일이 있다면 예시를 함께 제공하세요.
- **검증**: AI가 생성한 내용은 항상 검증하고 프로젝트에 맞게 수정하세요.

## 📚 추가 리소스

- [Claude Code 공식 문서](https://claude.com)
- [ChatGPT 프롬프트 가이드](https://platform.openai.com/docs)
- [Prompt Engineering Guide](https://www.promptingguide.ai/)
