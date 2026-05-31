import os
import uuid
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from firebase_admin import firestore
from app.firebase_config import db

router = APIRouter()

UPLOADS_DIR = "uploads"
os.makedirs(UPLOADS_DIR, exist_ok=True)

@router.post("/create")
def create_inventory_item(
    name: str = Form(...),
    description: str = Form(...),
    brand: str = Form(...),
    category: str = Form(...),
    price: float = Form(...),
    image: UploadFile = File(...)
):
    try:
        # Validate image type
        file_extension = os.path.splitext(image.filename)[1].lower()
        if file_extension not in [".jpg", ".jpeg", ".png", ".webp"]:
            raise HTTPException(
                status_code=400,
                detail="Only JPG, JPEG, PNG, and WEBP images are allowed"
            )

        # Save image locally
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = os.path.join(UPLOADS_DIR, unique_filename)
        with open(file_path, "wb") as f:
            f.write(image.file.read())

        # Build a URL that can be served via FastAPI static files
        image_url = f"http://127.0.0.1:8000/uploads/{unique_filename}"

        # Save metadata to Firestore
        item_data = {
            "name": name,
            "description": description,
            "brand": brand,
            "category": category,
            "price": price,
            "image_url": image_url,
            "local_path": file_path,
            "created_at": firestore.SERVER_TIMESTAMP,
            "updated_at": firestore.SERVER_TIMESTAMP,
        }

        doc_ref = db.collection("inventory").add(item_data)

        return {
            "message": "Inventory item created successfully",
            "item_id": doc_ref[1].id,
            "image_url": image_url
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/")
def get_all_inventory():
    try:
        docs = db.collection("inventory").stream()
        items = []
        for doc in docs:
            data = doc.to_dict()
            items.append({
                "item_id": doc.id,
                "name": data.get("name"),
                "description": data.get("description"),
                "brand": data.get("brand"),
                "category": data.get("category"),
                "price": data.get("price"),
                "image_url": data.get("image_url")
            })

        return {
            "count": len(items),
            "items": items,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/delete/{item_id}")
def delete_inventory_item(item_id: str):
    try:
        doc_ref = db.collection("inventory").document(item_id)
        doc = doc_ref.get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Item not found")

        # Delete local image file if it exists
        data = doc.to_dict()
        local_path = data.get("local_path")
        if local_path and os.path.exists(local_path):
            try:
                os.remove(local_path)
            except Exception as ex:
                print(f"Failed to delete local image: {ex}")

        # Delete from Firestore
        doc_ref.delete()

        return {
            "message": "Item deleted successfully",
            "item_id": item_id,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
