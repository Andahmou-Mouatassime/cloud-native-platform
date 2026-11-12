from fastapi import FastAPI, Request
from fastapi.responses import Response
from prometheus_client import (
    Counter,
    Histogram,
    generate_latest,
    CONTENT_TYPE_LATEST,
)
import time
import os
import socket

app = FastAPI(
    title="Cloud Native API",
    description="A cloud-native application deployed on AWS EKS",
    version="1.0.0",
)

# Prometheus metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total number of HTTP requests",
    ["method", "endpoint", "status_code"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"],
)

@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time.perf_counter()
    response = await call_next(request)
    duration = time.perf_counter() - start_time

    route = request.scope.get("route")
    endpoint = route.path if route else "unmatched"

    if endpoint != "/metrics":
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=endpoint,
            status_code=str(response.status_code),
        ).inc()

        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=endpoint,
        ).observe(duration)

    return response

@app.get("/")
async def root():
    return {
        "application": "cloud-native-api",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "pod": socket.gethostname(),
        "message": "Cloud Native API is running",
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy"
    }

@app.get("/api/v1/status")
async def application_status():
    return {
        "application": "cloud-native-api",
        "status": "operational",
        "environment": "development",
    }

@app.get("/metrics")
async def metrics():
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )