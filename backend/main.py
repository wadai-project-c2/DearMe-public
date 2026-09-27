from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from routers import health, images


app = FastAPI(
    title="DEAR ME Backend",
    description="DEAR MEの画像加工、3D化連携、保存処理を担当するAPI",
    version="0.1.0",
    docs_url="/docs" if settings.app_env.lower() == "local" else None,
    redoc_url="/redoc" if settings.app_env.lower() == "local" else None,
    openapi_url="/openapi.json" if settings.app_env.lower() == "local" else None,
)

# CORS is browser policy, NOT authentication. Native Flutter is not restricted
# by CORS. No cookies are used; app-token authentication remains mandatory.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(images.router)
