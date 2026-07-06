module layout;

import raylib;
import globals;

__gshared RenderTexture2D target;
__gshared Rectangle destRect;
__gshared bool ready = false;

private __gshared int lastAllocatedW = 0;
private __gshared int lastAllocatedH = 0;

void layoutInit() @nogc nothrow
{
	recompute();
}

void layoutShutdown() @nogc nothrow
{
	if (ready)
	{
		UnloadRenderTexture(target);
	}
}

// Manually trigger a UI/Viewport scale calculation on discrete events
void layoutForceTriggerRefresh() @nogc nothrow
{
	recompute();
}

private void recompute() @nogc nothrow
{
	int sw = GetScreenWidth();
	int sh = GetScreenHeight();

	// Avoid recreating the render texture if dimensions haven't changed
	if (!ready || sw != lastAllocatedW || sh != lastAllocatedH)
	{
		if (ready) UnloadRenderTexture(target);

		target = LoadRenderTexture(sw, sh);
		SetTextureFilter(target.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);

		lastAllocatedW = sw;
		lastAllocatedH = sh;
	}

	destRect = Rectangle(0, 0, cast(float)sw, cast(float)sh);
	ready = true;
}

void layoutBeginFrame() @nogc nothrow
{
	BeginTextureMode(target);
}

void layoutEndFrame() @nogc nothrow
{
	EndTextureMode();
	ClearBackground(Colors.BLACK);

	Rectangle src = Rectangle(0, 0, cast(float)lastAllocatedW, -cast(float)lastAllocatedH); // flip Y
	DrawTexturePro(target.texture, src, destRect, Vector2(0, 0), 0.0f, Colors.WHITE);
}

// Re-calculated 1:1 mouse position
Vector2 layoutMouse() @nogc nothrow
{
	return GetMousePosition();
}