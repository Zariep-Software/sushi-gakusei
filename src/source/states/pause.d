module states.pause;

import raylib;
import globals;
import assets;
import ui;

enum PauseAction : int { None, Resume, EndSession, Settings, MainMenu }

__gshared int selectedIdx = 0;

void pauseReset() @nogc nothrow
{
	selectedIdx = 0;
}

PauseAction pauseUpdateDraw() @nogc nothrow
{
	PauseAction result = PauseAction.None;

	float sw = cast(float)GetScreenWidth();
	float sh = cast(float)GetScreenHeight();

	DrawRectangle(0, 0, cast(int)sw, cast(int)sh, Color(40, 40, 40, 220));

	float w = 300, h = 300;
	float x = sw * 0.5f - w * 0.5f;
	float y = sh * 0.5f - h * 0.5f;

	int maxItems = 4;

	if (IsKeyPressed(KeyboardKey.KEY_UP))
	{
		selectedIdx--;
		if (selectedIdx < 0) selectedIdx = maxItems - 1;
	}
	if (IsKeyPressed(KeyboardKey.KEY_DOWN))
	{
		selectedIdx++;
		if (selectedIdx >= maxItems) selectedIdx = 0;
	}

	bool enterPressed = IsKeyPressed(KeyboardKey.KEY_ENTER) || IsKeyPressed(KeyboardKey.KEY_KP_ENTER);

	if (ui.spriteButton(Rectangle(x, y + 0, w, 56), "Resume", fontPotta, 30, selectedIdx == 0) || (enterPressed && selectedIdx == 0))
		result = PauseAction.Resume;

	if (ui.spriteButton(Rectangle(x, y + 68, w, 56), "End Run", fontPotta, 30, selectedIdx == 1) || (enterPressed && selectedIdx == 1))
		result = PauseAction.EndSession;

	if (ui.spriteButton(Rectangle(x, y + 136, w, 56), "Settings", fontPotta, 30, selectedIdx == 2) || (enterPressed && selectedIdx == 2))
		result = PauseAction.Settings;

	if (ui.spriteButton(Rectangle(x, y + 204, w, 56), "Main Menu", fontPotta, 30, selectedIdx == 3) || (enterPressed && selectedIdx == 3))
		result = PauseAction.MainMenu;

	if (IsKeyPressed(KeyboardKey.KEY_ESCAPE))
		result = PauseAction.Resume;

	return result;
}
