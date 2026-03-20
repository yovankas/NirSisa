"""
Smoke tests for API startup and health check.
"""

import os
import pytest
from fastapi.testclient import TestClient

# Skip if no Supabase credentials (e.g. local dev without .env)
pytestmark = pytest.mark.skipif(
    not os.getenv("SUPABASE_URL"),
    reason="SUPABASE_URL not set — skipping integration tests",
)


@pytest.fixture
def client():
    from app.main import app
    return TestClient(app)


def test_root(client):
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["app"] == "NirSisa API"


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "healthy"
    assert r.json()["database"] == "connected"


def test_inventory_requires_auth(client):
    r = client.get("/inventory")
    assert r.status_code in (401, 403)  # no JWT token


def test_recipes_requires_auth(client):
    r = client.get("/recipes")
    assert r.status_code in (401, 403)


def test_recommend_requires_auth(client):
    r = client.get("/recommend")
    assert r.status_code in (401, 403)
