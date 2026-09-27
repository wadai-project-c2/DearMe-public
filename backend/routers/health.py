from fastapi import APIRouter


router = APIRouter(
    prefix="/health",
    tags=["health"],
)


@router.get("")
def health_check():
    """
    backendが正常に動いているか確認するためのAPI。
    最初の動作確認に使う。
    """
    return {
        "status": "ok",
        "message": "DEAR ME backend is running",
    }