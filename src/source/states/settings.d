module states.settings;

import raylib;
import globals;
import assets;
import ui;
import save;
import layout;
import core.stdc.string : strcpy, strlen;
import core.stdc.stdio : snprintf;

/*
 TODO: Get a proper monitor modes list
 raylib doesn't enumerate monitor modes conveniently
 so keep the same common list and clamp to the current monitor size).
*/

private struct Res { int w; int h; }
private immutable Res[11] COMMON_RES =
[
	Res(640, 360), Res(768, 480), Res(854, 480), Res(1280, 720), Res(1280, 800),
	Res(1366, 768), Res(1440, 900), Res(1600, 900), Res(1920, 1080),
	Res(2560, 1440), Res(3840, 2160)
];

private __gshared int validResolutionCount = 1;
private __gshared Res[COMMON_RES.length + 1] validResolutions;

__gshared SettingsData current;
__gshared SettingsOrigin origin = SettingsOrigin.MainMenu;

private __gshared int waitingForAction = -1;
private __gshared KeyboardKey[6] bindings = [
	KeyboardKey.KEY_A, KeyboardKey.KEY_S, KeyboardKey.KEY_D, KeyboardKey.KEY_F,
	KeyboardKey.KEY_ESCAPE, KeyboardKey.KEY_ENTER
];

private immutable(char)*[6] ACTION_LABELS = [
	"Cut", "Slice", "Salt", "Vinegar", "Pause", "Accept"
];

void settingsInit() @nogc nothrow
{
	current = loadSettings();

	if (current.feedbackVolume <= 0 &&
		current.actionsVolume <= 0 &&
		current.musicVolume <= 0)
	{
		current.feedbackVolume = 1.0f;
		current.actionsVolume = 1.0f;
		current.musicVolume = 1.0f;
	}

	int monitor = GetCurrentMonitor();
	int maxW = GetMonitorWidth(monitor);
	int maxH = GetMonitorHeight(monitor);

	int count = 0;
	foreach (res; COMMON_RES)
	{
		if (res.w > maxW || res.h > maxH)
			break;
			validResolutions[count++] = res;
	}

	validResolutionCount = (count > 0) ? count : 1;
	if (count == 0)
		validResolutions[0] = COMMON_RES[0];

	if (current.resolutionIndex < 0)
	{
		version (WebAssembly)
		{
			int fallback = 0;
			foreach (i, res; COMMON_RES[0 .. validResolutionCount])
			{
				if (res.w == 854 && res.h == 480) { fallback = cast(int) i; break; }
			}
			current.resolutionIndex = fallback;
		}
		else
		{
			int defaultIndex = validResolutionCount - 2;
			if (defaultIndex < 0) defaultIndex = 0;
			current.resolutionIndex = defaultIndex;
		}
	}
	else if (current.resolutionIndex >= validResolutionCount)
	{
		current.resolutionIndex = validResolutionCount - 1;
	}

	selectedResolutionIndex = current.resolutionIndex;

	applyResolution();
}

KeyboardKey keyFor(int actionIndex) @nogc nothrow
{
	return bindings[actionIndex];
}

private __gshared bool resolutionListOpen = false;

private void applyResolution() @nogc nothrow
{
	auto res = validResolutions[current.resolutionIndex];
	SetWindowSize(res.w, res.h);
	saveSettings(current);
}

private void drawResolutionSelector(float x, float y) @nogc nothrow
{
	ui.centeredText("Resolution", fontFredoka, 18, x + 120, y, Colors.WHITE);
	y += 28;

	if (ui.button(Rectangle(x, y, 40, 40), "<", fontFredoka, 24))
	{
		if (selectedResolutionIndex > 0)
			selectedResolutionIndex--;
	}

	Rectangle center = Rectangle(x + 45, y, 150, 40);
	DrawRectangleRec(center, Color(55, 55, 55, 255));

	auto res = validResolutions[selectedResolutionIndex];

	char[32] text;
	snprintf(text.ptr, text.length, "%d x %d", res.w, res.h);

	Vector2 size = MeasureTextEx(fontFredoka, text.ptr, 18, 1);

	DrawTextEx(
		fontFredoka,
		text.ptr,
		Vector2(
			center.x + (center.width - size.x) * 0.5f,
			center.y + (center.height - size.y) * 0.5f),
			18,
			1,
			Colors.WHITE);

	if (ui.button(Rectangle(x + 200, y, 40, 40), ">", fontFredoka, 24))
	{
		if (selectedResolutionIndex < validResolutionCount - 1)
			selectedResolutionIndex++;
	}

	y += 52;

	if (ui.button(Rectangle(x, y, 240, 40), "Apply Resolution", fontFredoka, 18))
	{
		current.resolutionIndex = selectedResolutionIndex;
		applyResolution();
	}
}

private __gshared int selectedResolutionIndex = 0;
bool settingsUpdateDraw() @nogc nothrow
{
	bool close = false;

	DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Color(15, 15, 15, 255));
	ui.centeredText("Settings", fontFredoka, 44, SCREEN_WIDTH * 0.5f, 30, Colors.WHITE);

	// Center menu
	float totalContentWidth = 620.0f;
	float startX = (SCREEN_WIDTH - totalContentWidth) * 0.5f;

	float colX = startX;
	float col2X = startX + 380.0f;

	// Video
	float y = 120;

	ui.centeredText("Video", fontFredoka, 28, colX + 120, y, Colors.WHITE);
	y += 50;

	version (WebAssembly) {}
	else
	{
		drawResolutionSelector(colX, y);
		y += 130;
	}

	if (ui.button(Rectangle(colX, y, 240, 40), "Toggle Fullscreen", fontFredoka, 18))
	{
		current.fullscreen = !current.fullscreen;
		ToggleFullscreen();
		saveSettings(current);
	}

	y += 70;

	// Audio
	ui.centeredText("Audio", fontFredoka, 28, colX + 120, y, Colors.WHITE);
	y += 40;

	drawVolumeSlider(colX, y, "Feedback", current.feedbackVolume);
	y += 50;

	drawVolumeSlider(colX, y, "Actions", current.actionsVolume);
	y += 50;

	// drawVolumeSlider(colX, y, "Music", current.musicVolume);

	// Controls
	float cy = 170;

	ui.centeredText("Controls", fontFredoka, 28, col2X + 120, 120, Colors.WHITE);

	foreach (i, label; ACTION_LABELS)
	{
		char[64] buf;
		const(char)* key = keyName(bindings[i]);

		snprintfLabel(buf.ptr, 64, label, key);

		const(char)* shown =
		waitingForAction == i
		? "Press a key..."
		: buf.ptr;

		if (ui.button(Rectangle(col2X, cy, 240, 40), shown, fontFredoka, 18))
			waitingForAction = cast(int)i;

		cy += 50;
	}

	if (waitingForAction >= 0)
	{
		int key = GetKeyPressed();

		if (key != 0)
		{
			bindings[waitingForAction] = cast(KeyboardKey)key;
			waitingForAction = -1;
		}
	}

	if (ui.button(Rectangle(
		SCREEN_WIDTH * 0.5f - 80,
		SCREEN_HEIGHT - 70,
		160,
		48),
		"Close",
		fontFredoka,
		22)
		|| IsKeyPressed(KeyboardKey.KEY_ESCAPE))
	{
		close = true;
	}

	return close;
}

private void drawVolumeSlider(float x, float y, const(char)* label, ref float value) @nogc nothrow
{
	DrawTextEx(fontFredoka, label, Vector2(x, y), 18, 1.0f, Colors.WHITE);
	Rectangle track = Rectangle(x, y + 24, 220, 10);
	DrawRectangleRec(track, Color(60, 60, 60, 255));

	Rectangle fill = Rectangle(x, y + 24, 220 * value, 10);
	DrawRectangleRec(fill, Color(0, 180, 90, 255));

	Rectangle handle = Rectangle(x + 220 * value - 6, y + 18, 12, 22);
	DrawRectangleRec(handle, Colors.WHITE);

	if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT))
	{
		Vector2 m = layoutMouse();
		if (CheckCollisionPointRec(m, Rectangle(x - 8, y + 10, 236, 30)))
		{
			value = (m.x - x) / 220.0f;
			if (value < 0) value = 0;
			if (value > 1) value = 1;
			saveSettings(current);
		}
	}
}

private const(char)* keyName(KeyboardKey k) @nogc nothrow
{
	switch (k)
	{
		case KeyboardKey.KEY_A: return "A";
		case KeyboardKey.KEY_S: return "S";
		case KeyboardKey.KEY_D: return "D";
		case KeyboardKey.KEY_F: return "F";
		case KeyboardKey.KEY_ESCAPE: return "Esc";
		case KeyboardKey.KEY_ENTER: return "Enter";
		case KeyboardKey.KEY_SPACE: return "Space";
		default: return "?";
	}
}

private void snprintfLabel(char* buf, size_t n, const(char)* label, const(char)* key) @nogc nothrow
{
	snprintf(buf, n, "%s : %s", label, key);
}