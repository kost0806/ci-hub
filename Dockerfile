# Jekyll 문서 서버 Docker 이미지
FROM ruby:3.2-slim

# 작업 디렉토리 설정
WORKDIR /docs

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Gemfile 복사 및 의존성 설치
COPY docs/Gemfile* ./
RUN bundle install

# 포트 노출
EXPOSE 4000

# Jekyll 서버 실행 (로컬 개발용 설정 오버라이드)
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling", "--config", "_config.yml,_config_dev.yml"]
