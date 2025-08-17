# app/main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Auto-Pipe API",
    description="A demonstration FastAPI app for cloud deployment pipeline",
    version="1.0.0",
)


class Item(BaseModel):
    id: int
    name: str
    description: str = "A sample item"


class HealthResponse(BaseModel):
    status: str
    message: str


@app.get("/health", response_model=HealthResponse)
async def health():
    """Health check endpoint for load balancers and monitoring"""
    logger.info("Health check requested")
    return HealthResponse(status="ok", message="Service is healthy")


@app.get("/")
async def root():
    """Root endpoint"""
    return {"message": "Welcome to Auto-Pipe API", "docs": "/docs"}


@app.get("/items/{item_id}", response_model=Item)
async def read_item(item_id: int):
    """Get an item by ID"""
    if item_id < 1:
        logger.warning(f"Invalid item_id requested: {item_id}")
        raise HTTPException(status_code=400, detail="Item ID must be positive")

    logger.info(f"Item {item_id} requested")
    return Item(
        id=item_id, name=f"item-{item_id}", description=f"This is item number {item_id}"
    )


@app.post("/items", response_model=Item)
async def create_item(item: Item):
    """Create a new item"""
    logger.info(f"Creating item: {item.name}")
    return item


@app.get("/error")
async def trigger_error():
    """Endpoint to simulate errors for testing monitoring"""
    logger.error("Error endpoint triggered")
    raise HTTPException(status_code=500, detail="This is a test error")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
