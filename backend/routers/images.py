import logging
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response
from pydantic import ValidationError

from core.auth import require_api_token
from core.daily_quota import reserve_daily_attempt
from schemas.image_schema import ImageProcessRequest
from services.openai_image_service import process_image_with_openai

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/images",
    tags=["images"],
    dependencies=[Depends(require_api_token)],
)

_ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
# Function URL invokes Lambda synchronously. Keep binary bodies below 4 MiB so
# base64 encoding plus the event envelope stays safely below Lambda's 6 MiB cap.
_MAX_IMAGE_BYTES = 4 * 1024 * 1024


@router.post(
    "/process",
    response_class=Response,
    responses={200: {"content": {"image/png": {}}}},
)
async def process_image(
    http_request: Request,
    item_id: str = Query(..., min_length=1),
    title: str = Query(..., min_length=1, max_length=50),
    output_type: Literal["sticker_png", "acrylic_stand_png"] = Query(
        "sticker_png"
    ),
) -> Response:
    """Flutterから画像を受け取り、OpenAIで加工したPNGを直接返す。"""

    content_type = http_request.headers.get("content-type", "").split(";", 1)[0]
    if content_type not in _ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=415, detail="対応していない画像形式です。")

    content_length = http_request.headers.get("content-length")
    if content_length and content_length.isdigit():
        if int(content_length) > _MAX_IMAGE_BYTES:
            raise HTTPException(status_code=413, detail="画像サイズが大きすぎます。")

    # ヘッダーを偽装した巨大データも拒否できるよう、実データ長も確認する。
    image_bytes = await http_request.body()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="画像データが空です。")
    if len(image_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="画像サイズが大きすぎます。")

    try:
        metadata = ImageProcessRequest(
            item_id=item_id,
            title=title,
            output_type=output_type,
        )
    except ValidationError as error:
        raise HTTPException(status_code=422, detail="タイトルが正しくありません。") from error

    reserve_daily_attempt()
    try:
        processed_bytes = process_image_with_openai(
            metadata,
            image_bytes,
            content_type,
        )
    except Exception as error:
        # Provider exception bodies/tracebacks may contain credentials or input.
        logger.error(
            "Image processing via OpenAI failed: type=%s", type(error).__name__
        )
        raise HTTPException(
            status_code=502,
            detail="画像加工に失敗しました。",
        ) from error
    if len(processed_bytes) > _MAX_IMAGE_BYTES:
        logger.error(
            "Processed image exceeds Lambda response limit: bytes=%s",
            len(processed_bytes),
        )
        raise HTTPException(
            status_code=502,
            detail="加工済み画像のサイズが大きすぎます。",
        )

    return Response(
        content=processed_bytes,
        media_type="image/png",
        headers={
            "Cache-Control": "no-store",
            "X-Content-Type-Options": "nosniff",
        },
    )
