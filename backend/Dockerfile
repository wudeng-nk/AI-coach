FROM python:3.12-slim

WORKDIR /app

# Install system deps for asyncpg
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies (use China mirror)
COPY pyproject.toml .
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple/ .

# Copy source code
COPY . .

# Entryppoint handles DB migration + seed + server start
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
