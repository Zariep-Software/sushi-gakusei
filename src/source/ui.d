module ui;

import raylib;
import globals;
import layout;

struct ButtonInteraction
{
	bool hovered;
	bool down;
	bool released;
}

bool button(Rectangle rect, const(char)* label, Font font, int fontSize = 28) @nogc nothrow
{
	Vector2 mouse = layoutMouse();
	bool hovered = CheckCollisionPointRec(mouse, rect);

	bool pressed = false;
	version(Android)
	{
		if (hovered && IsGestureDetected(Gesture.GESTURE_TAP))
		{
			pressed = true;
		}
	}
	else
	{
		pressed = hovered && IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT);
	}

	Color bg = hovered ? Color(90, 90, 90, 255) : Color(60, 60, 60, 255);
	DrawRectangleRounded(rect, 0.25f, 8, bg);
	DrawRectangleRoundedLines(rect, 0.25f, 8, Colors.WHITE);

	Vector2 textSize = MeasureTextEx(font, label, fontSize, 1.0f);
	Vector2 pos = Vector2(
		rect.x + (rect.width - textSize.x) * 0.5f,
		rect.y + (rect.height - textSize.y) * 0.5f
	);
	DrawTextEx(font, label, pos, fontSize, 1.0f, Colors.WHITE);
	return pressed;
}

private immutable Color OUTLINE_DARK = Color(0x1a, 0x1a, 0x1a, 255);

bool spriteButton(Rectangle rect, const(char)* label, Font font, int fontSize = 30, bool selected = false) @nogc nothrow
{
	Vector2 mouse = layoutMouse();
	bool hovered = CheckCollisionPointRec(mouse, rect);
	bool down = hovered && IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT);
	bool pressed = hovered && IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT);

	Color fill, textColor;
	if (down)
	{
		fill = OUTLINE_DARK;
		textColor = Colors.WHITE;
	}
	else if (hovered || selected)
	{
		fill = Color(0xa6, 0xa6, 0xa6, 255);
		textColor = OUTLINE_DARK;
	}
	else
	{
		fill = Colors.WHITE;
		textColor = OUTLINE_DARK;
	}

	DrawRectangleRounded(rect, 0.3f, 8, fill);
	DrawRectangleRoundedLinesEx(rect, 0.3f, 8, 4.0f, OUTLINE_DARK);

	Vector2 textSize = MeasureTextEx(font, label, fontSize, 1.0f);
	Vector2 pos = Vector2(
		rect.x + (rect.width - textSize.x) * 0.5f,
		rect.y + (rect.height - textSize.y) * 0.5f
	);
	DrawTextEx(font, label, pos, fontSize, 1.0f, textColor);

	return pressed;
}

ButtonInteraction iconButtonInteract(Rectangle rect) @nogc nothrow
{
	Vector2 mouse = layoutMouse();
	bool hovered = CheckCollisionPointRec(mouse, rect);
	return ButtonInteraction(
		hovered,
		hovered && IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT),
		hovered && IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT)
	);
}

void drawIconScaled(Rectangle rect, Texture2D tex, Color tint, float scale) @nogc nothrow
{
	float w = rect.width * scale;
	float h = rect.height * scale;
	Rectangle dst = Rectangle(
		rect.x + (rect.width - w) * 0.5f,
		rect.y + (rect.height - h) * 0.5f,
		w, h
	);
	DrawTexturePro(tex, Rectangle(0, 0, cast(float) tex.width, cast(float) tex.height), dst, Vector2(0, 0), 0.0f, tint);
}

bool iconButton(Rectangle rect, Texture2D tex, bool dim) @nogc nothrow
{
	auto it = iconButtonInteract(rect);
	Color tint = dim ? Color(90, 90, 90, 255) : (it.hovered ? Color(200, 200, 200, 255) : Colors.WHITE);
	drawIconScaled(rect, tex, tint, 1.0f);
	return it.released;
}

void centeredText(const(char)* text, Font font, int fontSize, float centerX, float y, Color color) @nogc nothrow
{
	Vector2 size = MeasureTextEx(font, text, fontSize, 1.0f);
	DrawTextEx(font, text, Vector2(centerX - size.x * 0.5f, y), fontSize, 1.0f, color);
}

// Aspect-ratio aware texture placement //

// Largest rect that fits fully inside `bounds` while preserving the
// texture's aspect ratio (letterboxed, never crops). "Keep Aspect Fit"

Rectangle aspectFitRect(Texture2D tex, Rectangle bounds) @nogc nothrow
{
	float texRatio = tex.width / cast(float) tex.height;
	float boundsRatio = bounds.width / bounds.height;
	float w, h;
	if (texRatio > boundsRatio) { w = bounds.width; h = w / texRatio; }
	else { h = bounds.height; w = h * texRatio; }
	return Rectangle(bounds.x + (bounds.width - w) * 0.5f, bounds.y + (bounds.height - h) * 0.5f, w, h);
}

//  Smallest rect that fully covers `bounds` while preserving aspect ratio
// (crops / overflows rather than letterboxing). "Keep Aspect Centered"
Rectangle aspectCoverRect(Texture2D tex, Rectangle bounds) @nogc nothrow
{
	float texRatio = tex.width / cast(float) tex.height;
	float boundsRatio = bounds.width / bounds.height;
	float w, h;
	if (texRatio < boundsRatio) { w = bounds.width; h = w / texRatio; }
	else { h = bounds.height; w = h * texRatio; }
	return Rectangle(bounds.x + (bounds.width - w) * 0.5f, bounds.y + (bounds.height - h) * 0.5f, w, h);
}

void drawAspectFit(Texture2D tex, Rectangle bounds, Color tint) @nogc nothrow
{
	Rectangle dst = aspectFitRect(tex, bounds);
	DrawTexturePro(tex, Rectangle(0, 0, cast(float) tex.width, cast(float) tex.height), dst, Vector2(0, 0), 0.0f, tint);
}

//  Cover-mode draw; `bounds` may extend past the visible screen on
//  purpose (background overflow), the texture is simply clipped by
//  whatever is currently being rendered to (render texture / window)
void drawAspectCover(Texture2D tex, Rectangle bounds, Color tint) @nogc nothrow
{
	Rectangle dst = aspectCoverRect(tex, bounds);
	DrawTexturePro(tex, Rectangle(0, 0, cast(float) tex.width, cast(float) tex.height), dst, Vector2(0, 0), 0.0f, tint);
}