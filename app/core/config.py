import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "FastAPI App"
    DEBUG: bool = os.getenv("DEBUG", False)
    VERSION: str = "1.0.0"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./test.db")

    class Config:
        env_file = ".env"

settings = Settings()