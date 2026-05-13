from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import zone

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(zone.router, prefix="/zone", tags=["Zone"])

@app.get("/")
def root():
    return {"message": "Backend is running successfully"}