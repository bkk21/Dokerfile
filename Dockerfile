# Ubuntu 22.04 기반
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Asia/Seoul

# 기본 유틸 + 로케일/타임존
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common curl wget git vim nano unzip htop ca-certificates tzdata locales \
    build-essential gcc g++ make \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Python 3.11 설치
RUN add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3.11-distutils python3.11-dev python3-pip coreutils \
 && rm -rf /var/lib/apt/lists/*

# PostgreSQL 16 + pgvector (PGDG 저장소)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg lsb-release \
 && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && apt-get update && apt-get install -y --no-install-recommends \
    postgresql-16 postgresql-16-pgvector postgresql-client-16 \
 && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리
WORKDIR /app

# 파이썬 패키지 (Streamlit 포함)
# venv은 접속 후 만들어도 되지만, 여기선 전역 설치로 가볍게 셋업
RUN pip3 install --no-cache-dir --upgrade pip \
 && pip3 install --no-cache-dir \
    fastapi uvicorn[standard] streamlit requests pydantic python-dotenv psycopg2-binary

# 보기 좋은 프롬프트 & ls 색상
RUN echo 'export PS1="\[\033[1;32m\]\u@\h\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\[\033[1;31m\]\$\[\033[0m\] "' >> /root/.bashrc \
 && echo 'eval "$(dircolors -b)"' >> /root/.bashrc \
 && echo 'alias ls="ls --color=auto"' >> /root/.bashrc

# 참고: 내부 포트
EXPOSE 8501 8000 5432

# 기본은 bash로 진입(수동 실행 플로우)
CMD ["bash"]

