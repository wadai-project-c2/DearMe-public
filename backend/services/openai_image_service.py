import base64
import io
import logging

from openai import APIError, OpenAI

from core.config import settings
from core.prompt import DEARME_POP_IMAGE_PROMPT, TITLE_CONTEXT_TEMPLATE
from schemas.image_schema import ImageProcessRequest

logger = logging.getLogger(__name__)


def build_image_prompt(request: ImageProcessRequest) -> str:
    """固定の世界観指示に、命令として扱わない品物タイトルを追加する。"""

    title_context = TITLE_CONTEXT_TEMPLATE.format(title=request.title)
    prompt = f"{DEARME_POP_IMAGE_PROMPT}\n\n{title_context}"

    if request.output_type == "acrylic_stand_png":
        prompt += "\n\n追加条件:\n- アクリルスタンドのように、少し立体感のある見た目にしてください。"
    else:
        prompt += "\n\n追加条件:\n- シール帳に貼れるステッカーのような見た目にしてください。"

    return prompt


def process_image_with_openai(
    request: ImageProcessRequest,
    image_bytes: bytes,
    content_type: str,
) -> bytes:
    """画像をOpenAIへ送り、加工済みPNGのバイト列を返す。"""

    if not settings.openai_api_key:
        raise ValueError("OPENAI_API_KEY is not configured")
    if not image_bytes:
        raise ValueError("image is empty")

    extension = {
        "image/jpeg": "jpg",
        "image/png": "png",
        "image/webp": "webp",
    }.get(content_type)
    if extension is None:
        raise ValueError("unsupported image content type")

    # 一時ファイルを残さずAPIへ渡せるよう、受信画像をメモリ上のファイルにする。
    image_file = io.BytesIO(image_bytes)
    image_file.name = f"original.{extension}"
    # Each reserved attempt must issue at most one provider request.
    client = OpenAI(api_key=settings.openai_api_key, max_retries=0)
    try:
        result = client.images.edit(
            model="gpt-image-1",
            image=image_file,
            prompt=build_image_prompt(request),
            size="1024x1024",
            quality="medium",
            background="transparent",
            output_format="png",
        )
    except APIError as error:
        status_code = getattr(error, "status_code", None)
        logger.error(
            "OpenAI images.edit failed: status_code=%s",
            status_code,
        )
        raise

    image_base64 = result.data[0].b64_json
    if not image_base64:
        raise ValueError("OpenAI returned no image data")
    return base64.b64decode(image_base64)
