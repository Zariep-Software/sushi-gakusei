module states.help;

import raylib;
import globals;
import assets;
import ui;

private immutable(char)* HELP_TEXT =
	"Welcome to Sushi Gakusei!\n\n" ~
	"In this game, the teacher on the left performs a sequence of\n" ~
	"actions that you must memorize by watching and listening.\n\n" ~
	"The action buttons at the bottom show the icons for each\n" ~
	"possible action: Cut, Slice, Salt, and Vinegar.\n\n" ~
	"Repeat the sequence in the same order using those buttons.\n" ~
	"You have a limited number of mistakes before the run ends,\n" ~
	"unless you are playing in Endless Mode. At the end of a\n" ~
	"normal run you receive a grade based on your accuracy.";

private __gshared float scrollY = 0.0f;
private __gshared int teacherIndex = 0;
private __gshared bool teacherPicked = false;

/// Returns true when the player wants to go back to the main menu.
bool helpUpdateDraw() @nogc nothrow
{
	if (!teacherPicked)
	{
		teacherIndex = GetRandomValue(0, 1);
		teacherPicked = true;
	}

	float sw = cast(float)GetScreenWidth();
	float sh = cast(float)GetScreenHeight();

	DrawRectangle(0, 0, cast(int)sw, cast(int)sh, Color(20, 20, 20, 255));

	float imgW = sw * 0.35f;
	Texture2D teacher = teacherIndex == 0 ? assets.texTeacher[0] : assets.texTeacher[1];

	DrawTexturePro(teacher,
		Rectangle(0, 0, cast(float) teacher.width, cast(float) teacher.height),
		Rectangle(sw - imgW, 0, imgW, sh),
		Vector2(0, 0),
		0.0f,
		Colors.WHITE);

	float wheel = GetMouseWheelMove();
	scrollY -= wheel * 30;
	if (IsKeyDown(KeyboardKey.KEY_DOWN)) scrollY += 6;
	if (IsKeyDown(KeyboardKey.KEY_UP)) scrollY -= 6;
	if (scrollY < 0) scrollY = 0;

	Rectangle clip = Rectangle(40, 40, sw - imgW - 80, sh - 120);
	BeginScissorMode(cast(int) clip.x, cast(int) clip.y, cast(int) clip.width, cast(int) clip.height);
	DrawTextEx(fontFredoka, HELP_TEXT, Vector2(clip.x, clip.y - scrollY), 32, 1.0f, Colors.WHITE);

	EndScissorMode();

	bool back = false;
	if (ui.button(Rectangle(40, sh - 64, 160, 48), "Back", fontFredoka, 22)
		|| IsKeyPressed(KeyboardKey.KEY_ESCAPE))
	{
		back = true;
	}

	return back;
}

void helpReset() @nogc nothrow
{
	scrollY = 0.0f;
	teacherPicked = false;
}
