#!/bin/bash

# AI 설계 문서 로컬 서버 실행 스크립트 (Bash)

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 배너 출력
show_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║   AI 설계 문서 로컬 서버 (Docker)        ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# 도움말
show_help() {
    show_banner
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./run-docs.sh [명령어]"
    echo ""
    echo -e "${YELLOW}명령어:${NC}"
    echo "  start     - 문서 서버 시작 (기본값)"
    echo "  stop      - 문서 서버 중지"
    echo "  restart   - 문서 서버 재시작"
    echo "  logs      - 로그 보기"
    echo "  build     - Docker 이미지 다시 빌드"
    echo "  clean     - 컨테이너 및 볼륨 삭제"
    echo "  status    - 컨테이너 상태 확인"
    echo "  help      - 도움말 표시"
    echo ""
    echo -e "${YELLOW}예시:${NC}"
    echo "  ./run-docs.sh            # 서버 시작"
    echo "  ./run-docs.sh stop       # 서버 중지"
    echo "  ./run-docs.sh logs       # 로그 보기"
    echo ""
}

# Docker 설치 확인
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker가 설치되어 있지 않습니다.${NC}"
        echo "Docker를 설치해주세요: https://www.docker.com/get-started"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose가 설치되어 있지 않습니다.${NC}"
        echo "Docker Compose를 설치해주세요."
        exit 1
    fi
}

# 서버 시작
start_server() {
    show_banner
    echo -e "${GREEN}📦 Docker 컨테이너 시작 중...${NC}"

    check_docker
    docker-compose up -d

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ 서버가 시작되었습니다!${NC}"
        echo ""
        echo -e "${CYAN}📖 문서 보기:${NC}"
        echo -e "${YELLOW}   http://localhost:4000${NC}"
        echo ""
        echo -e "${CYAN}💡 팁:${NC}"
        echo "   - 문서를 수정하면 자동으로 새로고침됩니다 (LiveReload)"
        echo "   - 로그 보기: ./run-docs.sh logs"
        echo "   - 서버 중지: ./run-docs.sh stop"
        echo ""
    else
        echo -e "${RED}❌ 서버 시작 실패${NC}"
        exit 1
    fi
}

# 서버 중지
stop_server() {
    show_banner
    echo -e "${YELLOW}🛑 Docker 컨테이너 중지 중...${NC}"

    docker-compose down

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 서버가 중지되었습니다.${NC}"
    else
        echo -e "${RED}❌ 서버 중지 실패${NC}"
        exit 1
    fi
}

# 서버 재시작
restart_server() {
    show_banner
    echo -e "${YELLOW}🔄 서버 재시작 중...${NC}"

    docker-compose restart

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 서버가 재시작되었습니다.${NC}"
        echo -e "${YELLOW}   http://localhost:4000${NC}"
    else
        echo -e "${RED}❌ 서버 재시작 실패${NC}"
        exit 1
    fi
}

# 로그 보기
show_logs() {
    show_banner
    echo -e "${CYAN}📋 로그 표시 중... (Ctrl+C로 종료)${NC}"
    echo ""

    docker-compose logs -f
}

# 이미지 빌드
build_image() {
    show_banner
    echo -e "${YELLOW}🔨 Docker 이미지 빌드 중...${NC}"

    check_docker
    docker-compose build --no-cache

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 이미지 빌드 완료${NC}"
    else
        echo -e "${RED}❌ 이미지 빌드 실패${NC}"
        exit 1
    fi
}

# 정리
clean_all() {
    show_banner
    echo -e "${YELLOW}🧹 컨테이너 및 볼륨 삭제 중...${NC}"

    # 확인
    read -p "모든 컨테이너와 볼륨을 삭제하시겠습니까? (y/N) " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}취소되었습니다.${NC}"
        return
    fi

    docker-compose down -v

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 정리 완료${NC}"
    else
        echo -e "${RED}❌ 정리 실패${NC}"
        exit 1
    fi
}

# 상태 확인
show_status() {
    show_banner
    echo -e "${CYAN}📊 컨테이너 상태:${NC}"
    echo ""

    docker-compose ps
}

# 스크립트 실행 권한 확인
if [ ! -x "$0" ]; then
    echo -e "${YELLOW}⚠️  스크립트 실행 권한 설정 중...${NC}"
    chmod +x "$0"
    echo -e "${GREEN}✅ 완료${NC}"
fi

# 명령어 처리
COMMAND="${1:-start}"

case "$COMMAND" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        restart_server
        ;;
    logs)
        show_logs
        ;;
    build)
        build_image
        ;;
    clean)
        clean_all
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ 알 수 없는 명령어: $COMMAND${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
