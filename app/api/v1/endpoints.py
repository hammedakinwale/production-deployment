from fastapi import APIRouter
from app.models.item import Item
from datetime import datetime

router = APIRouter()

@router.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

@router.get("/items")
async def get_items():
    return {"items": ["item1", "item2", "item3"]}

@router.post("/items")
async def create_item(item: Item):
    return {"message": "Item created", "item": item}