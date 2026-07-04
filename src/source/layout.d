module layout;

import raylib;
import globals;

__gshared RenderTexture2D target;
__gshared Rectangle destRect;
__gshared bool ready = false;

void layoutInit() @nogc nothrow
{
	target = LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT);
	SetTextureFilter(target.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
	recompute();
	ready = true;
}

void layoutShutdown() @nogc nothrow
{
	UnloadRenderTexture(target);
}

void layoutRefreshIfNeeded() @nogc nothrow
{
	if (!ready || IsWindowResized())
	{
		recompute();
	}
}

private void recompute() @nogc nothrow
{
	float sw = cast(float) GetScreenWidth();
	float sh = cast(float) GetScreenHeight();
	float scale = sw / SCREEN_WIDTH < sh / SCREEN_HEIGHT ? sw / SCREEN_WIDTH : sh / SCREEN_HEIGHT;

	float w = SCREEN_WIDTH * scale;
	float h = SCREEN_HEIGHT * scale;
	destRect = Rectangle((sw - w) * 0.5f, (sh - h) * 0.5f, w, h);
	ready = true;
}

void layoutBeginFrame() @nogc nothrow
{
	layoutRefreshIfNeeded();
	BeginTextureMode(target);
}

void layoutEndFrame() @nogc nothrow
{
	EndTextureMode();
	ClearBackground(Colors.BLACK);
	Rectangle src = Rectangle(0, 0, SCREEN_WIDTH, -SCREEN_HEIGHT); // flip Y
	DrawTexturePro(target.texture, src, destRect, Vector2(0, 0), 0.0f, Colors.WHITE);
}

// Mouse position mapped from real window space into the fixed virtual spaced
Vector2 layoutMouse() @nogc nothrow
{
	Vector2 m = GetMousePosition();
	if (destRect.width <= 0 || destRect.height <= 0) return m;
	return Vector2(
		(m.x - destRect.x) * (SCREEN_WIDTH / destRect.width),
		(m.y - destRect.y) * (SCREEN_HEIGHT / destRect.height)
	);
}
