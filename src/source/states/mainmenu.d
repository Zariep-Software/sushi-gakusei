module states.mainmenu;

import raylib;
import globals;
import assets;
import ui;
import layout;

__gshared bool inModeSelect = false;
__gshared int selectedIdx = 0;

void mainMenuReset() @nogc nothrow
{
	inModeSelect = false;
	selectedIdx = 0;
}

enum MenuAction : int
{
	None,
	OpenSettings,
	OpenHelp,
	OpenAbout,
	Quit,
	StartOrder5,
	StartOrder10,
	StartOrder20,
	StartOrderEndless
}

MenuAction mainMenuUpdateDraw() @nogc nothrow
{
	MenuAction result = MenuAction.None;

	float sw = cast(float)GetScreenWidth();
	float sh = cast(float)GetScreenHeight();

	ui.drawAspectCover(texBackgroundFull, Rectangle(0, 0, sw, sh), Colors.WHITE);

	Rectangle logoBounds = Rectangle(60, sh * 0.5f - 256, 512, 512);
	ui.drawAspectFit(texLogo, logoBounds, Colors.WHITE);

	Rectangle infoRect = Rectangle(20, sh - 84, 64, 64);
	if (ui.iconButton(infoRect, texUiInformation, false))
		result = MenuAction.OpenAbout;

	float btnW = 340, btnH = 72, gap = 18;
	float x = sw - btnW - 130;
	float startY = sh * 0.5f;

	int maxItems = inModeSelect ? 5 : 4;

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

	if (!inModeSelect)
	{
		startY -= (btnH * 4 + gap * 3) * 0.5f;

		if (ui.spriteButton(Rectangle(x, startY + 0 * (btnH + gap), btnW, btnH), "Play", fontPotta, 30, selectedIdx == 0) || (enterPressed && selectedIdx == 0))
		{
			inModeSelect = true;
			selectedIdx = 0;
			enterPressed = false;
			layoutForceTriggerRefresh();
		}

		if (ui.spriteButton(Rectangle(x, startY + 1 * (btnH + gap), btnW, btnH), "Settings", fontPotta, 30, selectedIdx == 1) || (enterPressed && selectedIdx == 1))
			result = MenuAction.OpenSettings;

		if (ui.spriteButton(Rectangle(x, startY + 2 * (btnH + gap), btnW, btnH), "Help", fontPotta, 30, selectedIdx == 2) || (enterPressed && selectedIdx == 2))
			result = MenuAction.OpenHelp;

		version (WebAssembly) {}
		else
		{
			if (ui.spriteButton(Rectangle(x, startY + 3 * (btnH + gap), btnW, btnH), "Quit", fontPotta, 30, selectedIdx == 3) || (enterPressed && selectedIdx == 3))
				result = MenuAction.Quit;
		}
	}
	else
	{
		startY -= (btnH * 5 + gap * 4) * 0.5f;

		ui.centeredText("Choose a Mode", fontFredoka, 48, x + btnW * 0.5f, startY - 70, Colors.WHITE);

		if (ui.spriteButton(Rectangle(x, startY + 0 * (btnH + gap), btnW, btnH), "5 Orders", fontPotta, 30, selectedIdx == 0) || (enterPressed && selectedIdx == 0))
			result = MenuAction.StartOrder5;

		if (ui.spriteButton(Rectangle(x, startY + 1 * (btnH + gap), btnW, btnH), "10 Orders", fontPotta, 30, selectedIdx == 1) || (enterPressed && selectedIdx == 1))
			result = MenuAction.StartOrder10;

		if (ui.spriteButton(Rectangle(x, startY + 2 * (btnH + gap), btnW, btnH), "20 Orders", fontPotta, 30, selectedIdx == 2) || (enterPressed && selectedIdx == 2))
			result = MenuAction.StartOrder20;

		if (ui.spriteButton(Rectangle(x, startY + 3 * (btnH + gap), btnW, btnH), "Endless Mode", fontPotta, 30, selectedIdx == 3) || (enterPressed && selectedIdx == 3))
			result = MenuAction.StartOrderEndless;

		if (ui.spriteButton(Rectangle(x, startY + 4 * (btnH + gap), btnW, btnH), "Go Back", fontPotta, 30, selectedIdx == 4) || (enterPressed && selectedIdx == 4) || IsKeyPressed(KeyboardKey.KEY_ESCAPE))
		{
			inModeSelect = false;
			selectedIdx = 0;
			layoutForceTriggerRefresh();
		}
	}

	if (result != MenuAction.None)
	{
		layoutForceTriggerRefresh();
	}
	return result;
}
