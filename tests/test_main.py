from fastapi.testclient import TestClient
from app.main import app

# Create a test client
client = TestClient(app)


def test_health_endpoint():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "message" in data


def test_root_endpoint():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "docs" in data


def test_read_item_valid():
    """Test reading a valid item"""
    item_id = 5
    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == item_id
    assert data["name"] == f"item-{item_id}"
    assert "description" in data


def test_read_item_invalid():
    """Test reading an item with invalid ID"""
    response = client.get("/items/0")
    assert response.status_code == 400
    data = response.json()
    assert "detail" in data


def test_create_item():
    """Test creating a new item"""
    new_item = {"id": 1, "name": "test-item", "description": "A test item"}
    response = client.post("/items", json=new_item)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == new_item["id"]
    assert data["name"] == new_item["name"]


def test_error_endpoint():
    """Test the error endpoint for monitoring testing"""
    response = client.get("/error")
    assert response.status_code == 500
