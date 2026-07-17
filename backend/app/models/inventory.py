from pydantic import BaseModel
from typing import Optional

class InventoryItemBase(BaseModel):
    name: str
    description: str
    brand: str
    category: str
    price: float

class InventoryItemCreate(InventoryItemBase):
    pass

class InventoryItemUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    brand: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = None
