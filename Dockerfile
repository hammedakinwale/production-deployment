# Stage 1: Build
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt
COPY app/ /app

# Stage 2: Runtime (distroless)
FROM gcr.io/distroless/python3-debian11
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /app /app
# Drop privileges
RUN adduser -D KUBE_USER
USER KUBE_USER
EXPOSE APIPORT
CMD ["-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "APIPORT"]