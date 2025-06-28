from fastapi import FastAPI
from app.api.v1.endpoints import router

app = FastAPI()

app.include_router(router)

@app.on_event("shutdown")
def shutdown_event():
    print("App shutting down...")