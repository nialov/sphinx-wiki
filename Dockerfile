FROM python:3.8.12-bullseye

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1

WORKDIR /app

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.1.11

RUN apt-get update \
 && apt-get install -y \
    build-essential git gfortran \
    cmake curl wget unzip libreadline-dev libjpeg-dev libpng-dev ncurses-dev \
    libssl-dev libzmq3-dev

COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --requirement requirements.txt

EXPOSE 8000

COPY docker-entrypoint.sh ./
CMD ["./docker-entrypoint.sh"]
