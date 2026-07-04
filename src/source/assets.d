module assets;

import raylib;
import globals;

/*
	Central asset store. Loaded once in `assetsLoad()` (called from ready())
	and released in `assetsUnload()`. Kept as module-level statics so every
	state module can reach them without passing a big struct everywhere.
*/

__gshared
{
	// Fonts
	Font fontFredoka;
	Font fontPotta;

	// Backgrounds / UI
	Texture2D texBackground;
	Texture2D texBackgroundFull;
	Texture2D texWorkbench;
	Texture2D texLogo;
	Texture2D texButton;
	Texture2D texUiPause;
	Texture2D texUiInformation;

	// Action icons (buttons)
	Texture2D texCut;
	Texture2D texSlice;
	Texture2D texSalt;
	Texture2D texVinegar;

	// Workbench tools
	Texture2D texObjKnife;
	Texture2D texObjSalt;
	Texture2D texObjVinegar;

	// Action animation sprites
	Texture2D texAnimCut;
	Texture2D texAnimSlice;
	Texture2D texAnimSalt;
	Texture2D texAnimVinegar;

	// Sushi variants
	Texture2D[4] texSushi;

	// Teacher portraits
	Texture2D[2] texTeacher;

	// SFX
	Sound sfxCut;
	Sound sfxSlice;
	Sound sfxSalt;
	Sound sfxVinegar;
	Sound sfxWrong;
	Sound sfxDone;
}

void assetsLoad() @nogc nothrow
{
	fontFredoka = LoadFont(FONT_FREDOKA);
	fontPotta = LoadFont(FONT_POTTA);

	texBackground = LoadTexture(ASSET_IMG ~ "background.png");
	texBackgroundFull = LoadTexture(ASSET_IMG ~ "background_full.png");
	texWorkbench = LoadTexture(ASSET_IMG ~ "workbench.png");
	texLogo = LoadTexture(ASSET_IMG ~ "logo.png");
	texButton = LoadTexture(ASSET_IMG ~ "button.png");
	texUiPause = LoadTexture(ASSET_IMG ~ "ui_pause.png");
	texUiInformation = LoadTexture(ASSET_IMG ~ "ui_information.png");

	texCut = LoadTexture(ASSET_IMG ~ "cut.png");
	texSlice = LoadTexture(ASSET_IMG ~ "slice.png");
	texSalt = LoadTexture(ASSET_IMG ~ "salt.png");
	texVinegar = LoadTexture(ASSET_IMG ~ "vinegar.png");

	texObjKnife = LoadTexture(ASSET_IMG ~ "obj_knife.png");
	texObjSalt = LoadTexture(ASSET_IMG ~ "obj_salt.png");
	texObjVinegar = LoadTexture(ASSET_IMG ~ "obj_vinegar.png");

	texAnimCut = LoadTexture(ASSET_IMG ~ "anim_cut.png");
	texAnimSlice = LoadTexture(ASSET_IMG ~ "anim_slice.png");
	texAnimSalt = LoadTexture(ASSET_IMG ~ "anim_salt.png");
	texAnimVinegar = LoadTexture(ASSET_IMG ~ "anim_vinager.png");

	texSushi[0] = LoadTexture(ASSET_IMG ~ "sushi1.png");
	texSushi[1] = LoadTexture(ASSET_IMG ~ "sushi2.png");
	texSushi[2] = LoadTexture(ASSET_IMG ~ "sushi3.png");
	texSushi[3] = LoadTexture(ASSET_IMG ~ "sushi4.png");

	texTeacher[0] = LoadTexture(ASSET_IMG ~ "teacher0.png");
	texTeacher[1] = LoadTexture(ASSET_IMG ~ "teacher1.png");

	sfxCut = LoadSound(ASSET_SFX ~ "cut.ogg");
	sfxSlice = LoadSound(ASSET_SFX ~ "slice.ogg");
	sfxSalt = LoadSound(ASSET_SFX ~ "salt.ogg");
	sfxVinegar = LoadSound(ASSET_SFX ~ "vinegar.ogg");
	sfxWrong = LoadSound(ASSET_SFX ~ "wrong.ogg");
	sfxDone = LoadSound(ASSET_SFX ~ "done.ogg");
}

void assetsUnload() @nogc nothrow
{
	UnloadFont(fontFredoka);
	UnloadFont(fontPotta);

	UnloadTexture(texBackground);
	UnloadTexture(texBackgroundFull);
	UnloadTexture(texWorkbench);
	UnloadTexture(texLogo);
	UnloadTexture(texButton);
	UnloadTexture(texUiPause);
	UnloadTexture(texUiInformation);

	UnloadTexture(texCut);
	UnloadTexture(texSlice);
	UnloadTexture(texSalt);
	UnloadTexture(texVinegar);

	UnloadTexture(texObjKnife);
	UnloadTexture(texObjSalt);
	UnloadTexture(texObjVinegar);

	UnloadTexture(texAnimCut);
	UnloadTexture(texAnimSlice);
	UnloadTexture(texAnimSalt);
	UnloadTexture(texAnimVinegar);

	foreach (ref t; texSushi) UnloadTexture(t);
	foreach (ref t; texTeacher) UnloadTexture(t);

	UnloadSound(sfxCut);
	UnloadSound(sfxSlice);
	UnloadSound(sfxSalt);
	UnloadSound(sfxVinegar);
	UnloadSound(sfxWrong);
	UnloadSound(sfxDone);
}

// Returns the texture matching a given action's button icon.
Texture2D* actionIcon(Action a) @nogc nothrow
{
	final switch (a)
	{
		case Action.CUT: return &texCut;
		case Action.SLICE: return &texSlice;
		case Action.SALT: return &texSalt;
		case Action.VINEGAR: return &texVinegar;
	}
}

Sound* actionSound(Action a) @nogc nothrow
{
	final switch (a)
	{
		case Action.CUT: return &sfxCut;
		case Action.SLICE: return &sfxSlice;
		case Action.SALT: return &sfxSalt;
		case Action.VINEGAR: return &sfxVinegar;
	}
}

Texture2D* actionAnim(Action a) @nogc nothrow
{
	final switch (a)
	{
		case Action.CUT: return &texAnimCut;
		case Action.SLICE: return &texAnimSlice;
		case Action.SALT: return &texAnimSalt;
		case Action.VINEGAR: return &texAnimVinegar;
	}
}
