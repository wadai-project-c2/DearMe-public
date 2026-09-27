from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ImageProcessRequest(BaseModel):
    """Flutterから直接送られる1枚の画像に付随する加工条件。"""

    model_config = ConfigDict(extra="forbid")

    item_id: str = Field(..., min_length=1, description="Item identifier")
    title: str = Field(
        ...,
        min_length=1,
        max_length=50,
        description="Title used only as visual subject context",
    )
    output_type: Literal["sticker_png", "acrylic_stand_png"] = "sticker_png"

    @field_validator("title")
    @classmethod
    def validate_title(cls, value: str) -> str:
        normalized = value.strip()
        if not normalized:
            raise ValueError("title must contain at least one visible character")
        if any(ord(character) < 32 or ord(character) == 127 for character in normalized):
            raise ValueError("title must not contain control characters")
        return normalized
