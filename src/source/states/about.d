module states.about;

import raylib;
import globals;
import assets;
import ui;
import core.stdc.stdio : snprintf;

version (WebAssembly)
	extern (C) @nogc nothrow void emscripten_run_script(const(char)* script);

version (Windows)
	import core.sys.windows.windows : ShellExecuteA, SW_SHOWNORMAL;

version (OSX)
	import core.stdc.stdlib : system;

version (linux)
	import core.stdc.stdlib : system;

void openUrl(const(char)* url) @nogc nothrow
{
	version (WebAssembly)
	{
		char[256] script;
		snprintf(script.ptr, script.length, "window.open('%s', '_blank');", url);
		emscripten_run_script(script.ptr);
	}
	else version (Windows)
	{
		ShellExecuteA(null, "open", url, null, null, SW_SHOWNORMAL);
	}
	else version (OSX)
	{
		char[300] cmd;
		snprintf(cmd.ptr, cmd.length, "open '%s'", url);
		system(cmd.ptr);
	}
	else version (linux)
	{
			char[300] cmd;
			snprintf(cmd.ptr, cmd.length, "xdg-open '%s' &", url);
			system(cmd.ptr);
	}
	else version (Android)
	{
		// TODO: Call a JNI Call to open the URL
	}
}

private enum CreditsPanel : int { None, Audio, Fonts }
private __gshared CreditsPanel activePanel = CreditsPanel.None;

private immutable(char)* AUDIO_CREDITS =
	"External SFX Resources\n\n" ~
	"Sonniss.com GDC Game Audio Bundles:\n" ~
	" - vinegar.ogg (Wav Junction - Glassware)\n" ~
	" - slice.ogg (Coll Anderson - Gore)\n" ~
	" - cut.ogg (Soundopolis - Gore Toolkit HD)\n" ~
	" - wrong.ogg (Scoba Sounds - UI Essentials)\n" ~
	" - done.ogg (SmartSoundFX - User Interaction)\n\n" ~
	"Freesound.org:\n" ~
	" - salt.ogg (TimoCoetzee200014 - salt-shaker.wav)";

private immutable(char)* FONTS_CREDITS = "Fredoka One by hafontia\nPotta One by go108go";

// Returns true when the user closed the About screen entirely
bool aboutUpdateDraw() @nogc nothrow
{
	bool closed = false;

	DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Color(0, 0, 0, 180));

	Rectangle panel = Rectangle(SCREEN_WIDTH * 0.5f - 250, SCREEN_HEIGHT * 0.5f - 187, 500, 374);
	DrawRectangleRounded(panel, 0.05f, 8, Color(10, 10, 10, 255));
	DrawRectangleRoundedLines(panel, 0.05f, 8, Colors.WHITE);

	if (activePanel != CreditsPanel.None)
	{
		Rectangle inner = Rectangle(panel.x + 20, panel.y + 20, panel.width - 40, panel.height - 90);
		const(char)* text = activePanel == CreditsPanel.Audio ? AUDIO_CREDITS : FONTS_CREDITS;
		DrawTextEx(fontFredoka, text, Vector2(inner.x, inner.y), 20, 1.0f, Colors.WHITE);

		if (ui.button(Rectangle(panel.x + panel.width * 0.5f - 60, panel.y + panel.height - 60, 120, 44), "Close", fontFredoka, 22))
		{
			activePanel = CreditsPanel.None;
		}

		return closed;
	}

	float px = panel.x + 20, py = panel.y + 20;
	ui.drawAspectFit(texLogo, Rectangle(px, py, 64, 64), Colors.WHITE);

	ui.centeredText("v1.1", fontFredoka, 22, px + 140, py + 20, Colors.WHITE);

	float by = py + 90;
	if (ui.button(Rectangle(px, by, 220, 44), "ItsZariep (Code+Sprites)", fontFredoka, 20))
		openUrl("https://github.com/ItsZariep");
	if (ui.button(Rectangle(px, by + 54, 220, 44), "Audio credits", fontFredoka, 20))
		activePanel = CreditsPanel.Audio;
	if (ui.button(Rectangle(px, by + 108, 220, 44), "Fonts credits", fontFredoka, 20))
		activePanel = CreditsPanel.Fonts;
	if (ui.button(Rectangle(px, by + 162, 220, 44), "Itch.io page", fontFredoka, 20))
		openUrl("https://itszariep.itch.io/sushi-gakusei");
	if (ui.button(Rectangle(px + 240, by, 220, 44), "Source Code", fontFredoka, 20))
		openUrl("https://github.com/Zariep-Software/sushi-gakusei");
	if (ui.button(Rectangle(px + 240, by + 54, 220, 44), "Made with Raylib", fontFredoka, 20))
		openUrl("https://www.raylib.com");

	if (ui.button(Rectangle(panel.x + panel.width * 0.5f - 60, panel.y + panel.height - 55, 120, 40), "Close", fontFredoka, 22)
		|| IsKeyPressed(KeyboardKey.KEY_ESCAPE))
		closed = true;

	return closed;
}

void aboutReset() @nogc nothrow
{
	activePanel = CreditsPanel.None;
}
