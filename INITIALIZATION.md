## 1. 프로젝트 개요

| 항목          | 내용                                                                                         |
|-------------|--------------------------------------------------------------------------------------------|
| **프로젝트명**   | CI 셋업을 간편하게 해주는 허브                                                                         |
| **한 줄 설명**  | Github Repository / Github Actions / Jenkins / SonarQube 등 CI 도구들을 정해진 템플릿대로 한번에 셋업해주는 Hub |
| **프로젝트 유형** | 웹 애플리케이션                                                                                   |
| **현재 단계**   | 아이디어 / 기획                                                                                  |

## 2. 배경 및 동기

### 해결하려는 문제
사용하는 기술 스택이 매우 유사한 프로젝트간에 Github Repository 구조가 일정하지 않고, 이로인한 CI 도구 활용이 원활하지 않은 문제가 있음.

특히 Jenkins의 경우, 생소한 Groovy 기반 DSL을 사용하는 문제로 인해 빌드 스크립트 작성에 어려움을 겪고, Github Actions도 YAML로 복잡한 CI를 구축해야 해서 도입 조차 하지 않는 경우가 존재. 

### 기존 대안과 한계
Jenkins 빌드 Configuration 구성시에 이전 작성된 Build script를 참고하지만, 이해도 부족으로 인해 직접 수정에 어려움을 겪음.

## 3. 목표
템플릿화 된 CI 도구 설정을 이용해 쉬운 프로젝트 CI 설정

### 핵심 목표
1. 웹 서비스에서 몇번의 입력 및 선택으로 Github Repository, Github Actions, Jenkins, SonarQube 설정을 완료한다.
2. 프로젝트별 기술스택을 고려하여 빌드 / 테스트 등의 단계를 자동으로 지정할 수 있게 한다.
3. 프로젝트별 차이를 지원하기 위해 customize 된 CI 설정을 할 수 있도록 지원한다.

### 성공 기준
- 설정 완료된 CI 확인
  - GitHub Repository
  - GitHub Actions
  - Jenkins Build Configuration
  - SonarQube Project

## 4. 대상 사용자

| 사용자 유형      | 설명                | 주요 니즈                                                 |
|-------------|-------------------|-------------------------------------------------------|
| 서비스 개발자     | 프로젝트 개발에 참여하는 개발자 | CI 셋업을 편하게 하고 싶음. GitHub Actions나 Jenkins 등의 DSL이 어려움 |

## 5. 핵심 기능 (MVP)

> 최소 기능 제품(MVP) 범위에서 반드시 포함되어야 할 기능을 나열하세요.

1. GitHub Actions : 최소한의 CI를 위한 Workflow를 자동 추가한다. 추가할 Workflow는 별도 Branch로 작업하여 PR까지 생성해주는걸 목표로 한다.
2. Jenkins Setup: 템플릿화 된 Build Configuration을 이용해 원하는 Build Configuration을 설정한다. 
3. SonarQube: GitHub Actions와 연계하여 PR Decorator 까지 생성하는걸 목표로 한다.

## 6. 기술 제약 및 선호

### 확정된 제약사항
- **언어/프레임워크**: TypeScript, React, Kotlin, Spring Boot
- **데이터베이스**: PostgreSQL
- **인프라**: Docker
- **기타**: Keycloak 인증

### 선호사항 (변경 가능)
- 모노레포 구조
- Build된 FE의 static file을 BE가 serving


## 7. 일정 및 제약
*해당사항 없음*

## 8. 참고 자료
*해당사항 없음*

