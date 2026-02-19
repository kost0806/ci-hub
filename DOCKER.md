# Docker 사용 가이드 🐳

로컬 환경에서 Docker를 사용하여 문서 서버를 실행하는 방법입니다.

## 📋 사전 요구사항

### Docker Desktop 설치

**Windows:**
- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) 다운로드 및 설치
- WSL 2 활성화 권장

**macOS:**
- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop) 다운로드 및 설치

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose 설치
sudo apt-get install docker-compose-plugin
```

### Docker 설치 확인
```bash
docker --version
docker-compose --version
```

---

## 🚀 빠른 시작

### Windows (PowerShell)

```powershell
# 서버 시작
.\run-docs.ps1 start

# 브라우저에서 http://localhost:4000 접속
```

### macOS / Linux

```bash
# 실행 권한 부여 (최초 1회)
chmod +x run-docs.sh

# 서버 시작
./run-docs.sh start

# 브라우저에서 http://localhost:4000 접속
```

---

## 📖 명령어 레퍼런스

### 서버 관리

#### 시작
```bash
# Windows
.\run-docs.ps1 start

# macOS/Linux
./run-docs.sh start
```
- 문서 서버를 백그라운드로 시작
- LiveReload 자동 활성화
- 포트: 4000 (HTTP), 35729 (LiveReload)

#### 중지
```bash
# Windows
.\run-docs.ps1 stop

# macOS/Linux
./run-docs.sh stop
```
- 실행 중인 컨테이너 중지
- 데이터는 유지됨

#### 재시작
```bash
# Windows
.\run-docs.ps1 restart

# macOS/Linux
./run-docs.sh restart
```
- 설정 변경 후 재시작 필요 시 사용

---

### 모니터링

#### 로그 보기
```bash
# Windows
.\run-docs.ps1 logs

# macOS/Linux
./run-docs.sh logs
```
- 실시간 로그 스트림
- `Ctrl + C`로 종료

#### 상태 확인
```bash
# Windows
.\run-docs.ps1 status

# macOS/Linux
./run-docs.sh status
```
- 컨테이너 실행 상태 확인

---

### 고급 기능

#### 이미지 재빌드
```bash
# Windows
.\run-docs.ps1 build

# macOS/Linux
./run-docs.sh build
```
- Gemfile 변경 시 필요
- 의존성 업데이트 시 사용

#### 전체 정리
```bash
# Windows
.\run-docs.ps1 clean

# macOS/Linux
./run-docs.sh clean
```
- 모든 컨테이너 및 볼륨 삭제
- 깨끗한 상태로 재시작 필요 시 사용

---

## 🔧 문제 해결

### 포트가 이미 사용 중

**증상:**
```
Error: port 4000 is already allocated
```

**해결:**
1. 다른 Jekyll 서버 종료
2. 또는 `docker-compose.yaml`에서 포트 변경:
   ```yaml
   ports:
     - "4001:4000"  # 4001로 변경
   ```

### 권한 오류 (Linux/macOS)

**증상:**
```
permission denied while trying to connect to the Docker daemon
```

**해결:**
```bash
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

### 빌드 실패

**해결:**
```bash
# 캐시 없이 재빌드
docker-compose build --no-cache

# 또는 스크립트 사용
./run-docs.sh build
```

### LiveReload 작동 안 함

**확인 사항:**
1. 포트 35729가 열려 있는지 확인
2. 브라우저 콘솔에서 WebSocket 연결 확인
3. 방화벽 설정 확인

---

## 📁 디렉토리 구조

```
design-document-by-ai-template/
├── Dockerfile              # Jekyll 이미지 정의
├── docker-compose.yaml     # 서비스 구성
├── run-docs.ps1           # Windows 스크립트
├── run-docs.sh            # macOS/Linux 스크립트
└── docs/                  # 문서 소스 (마운트됨)
    ├── _config.yml
    ├── Gemfile
    └── ...
```

---

## ⚡ LiveReload 기능

문서를 수정하면 자동으로 브라우저가 새로고침됩니다!

**지원 파일:**
- `.md` (마크다운)
- `.html`
- `.css`
- `.js`
- `_config.yml`

**_config.yml 변경 시:**
서버 재시작 필요:
```bash
./run-docs.sh restart
```

---

## 🎨 커스터마이징

### 포트 변경

`docker-compose.yaml` 수정:
```yaml
services:
  jekyll:
    ports:
      - "8080:4000"      # 8080으로 변경
      - "35729:35729"
```

### 환경 변수 추가

`docker-compose.yaml`에 추가:
```yaml
services:
  jekyll:
    environment:
      - JEKYLL_ENV=development
      - TZ=Asia/Seoul        # 타임존 설정
```

---

## 🔍 Docker Compose 직접 사용

스크립트 없이 직접 Docker Compose 명령어 사용:

```bash
# 시작 (포어그라운드)
docker-compose up

# 시작 (백그라운드)
docker-compose up -d

# 중지
docker-compose down

# 로그
docker-compose logs -f

# 재빌드
docker-compose build

# 전체 삭제 (볼륨 포함)
docker-compose down -v
```

---

## 📊 성능 최적화

### Windows에서 WSL 2 사용

1. Docker Desktop 설정 → Resources → WSL Integration
2. 프로젝트를 WSL 파일시스템에 배치:
   ```bash
   # WSL 내에서
   cd ~
   git clone <repo>
   ```

### 볼륨 캐싱

`docker-compose.yaml`에 이미 최적화 설정됨:
- Bundle 캐시 볼륨 사용
- 빠른 gem 설치

---

## 🆘 도움말

스크립트 도움말 보기:

```bash
# Windows
.\run-docs.ps1 help

# macOS/Linux
./run-docs.sh help
```

---

## 📚 추가 리소스

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)

---

**Happy Documenting! 🚀**
