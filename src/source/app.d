module app;

import raylib;
import globals;
import assets;
import ui;
import layout;

import mainmenu = states.mainmenu;
import help = states.help;
import settingsState = states.settings;
import gameState = states.game;
import gameOver = states.gameover;
import about = states.about;
import pauseState = states.pause;

__gshared AppState currentState = AppState.MainMenu;
__gshared bool showAbout = false;
__gshared bool showSettings = false;
__gshared bool showPause = false;
__gshared bool wantQuit = false;

// Emscripten functions
version (WebAssembly)
{
	extern (C) @system nothrow @nogc
	void emscripten_set_main_loop(void* ptr, int fps, bool loop);
	extern (C) @system nothrow @nogc
	void emscripten_cancel_main_loop();
}

version (D_BetterC)
{
	extern (C) void main() { ready(); }
}
else
{
	void main() { ready(); }
}

void setRandomWindowIcon() @nogc nothrow
{
	Image icon;

	final switch (GetRandomValue(0, 3))
	{
		case 0: icon = LoadImage(ASSET_IMG ~ "sushi1.png"); break;
		case 1: icon = LoadImage(ASSET_IMG ~ "sushi2.png"); break;
		case 2: icon = LoadImage(ASSET_IMG ~ "sushi3.png"); break;
		case 3: icon = LoadImage(ASSET_IMG ~ "sushi4.png"); break;
	}

	SetWindowIcon(icon);
	UnloadImage(icon);
}

void ready() @nogc nothrow
{
	SetConfigFlags(ConfigFlags.FLAG_VSYNC_HINT | ConfigFlags.FLAG_WINDOW_RESIZABLE); // Make sure resizable flag is on

	version(Android)
	{
		InitWindow(0, 0, "Sushi Gakusei");
	}
	else
	{
		InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Sushi Gakusei");
		setRandomWindowIcon();
	}

	InitAudioDevice();
	SetExitKey(KeyboardKey.KEY_NULL);

	assetsLoad();
	settingsState.settingsInit();
	layoutInit();

	version (WebAssembly)
	{
		emscripten_set_main_loop(&frame, 0, true);
	}
	else
	{
		SetTargetFPS(TARGET_FPS);
		while (!WindowShouldClose() && !wantQuit)
		{
			frame();
		}
		shutdown();
		version (Android)
		{
			// prevents bug where app closes if not fully closed
			import core.stdc.stdlib : exit;
			exit(0);
		}
	}
}

void shutdown() @nogc nothrow
{
	layoutShutdown();
	assetsUnload();
	CloseAudioDevice();
	CloseWindow();
}

extern (C) void frame() @nogc nothrow
{
	float dt = GetFrameTime();

	BeginDrawing();
	layoutBeginFrame();
	ClearBackground(Colors.BLACK);

	final switch (currentState)
	{
		case AppState.MainMenu:
		case AppState.ModeSelect:
			updateDrawMainMenu();
			break;

		case AppState.Help:
			updateDrawHelp();
			break;

		case AppState.Settings:
			updateDrawSettingsStandalone();
			break;

		case AppState.Game:
			updateDrawGame(dt);
			break;

		case AppState.GameOver:
			updateDrawGameOver();
			break;

		case AppState.About:
			// Unreachable: About is drawn as an overlay.
			break;
	}

	// Overlays (drawn regardless of base state:
	// CanvasLayer stacking of About/Settings/Pause on top of Main)
	if (showAbout)
	{
		if (about.aboutUpdateDraw())
		{
			showAbout = false;
			layoutForceTriggerRefresh();
		}
	}

	layoutEndFrame();
	EndDrawing();

	version (WebAssembly)
	{
		if (wantQuit)
			emscripten_cancel_main_loop();
	}
}

private void updateDrawMainMenu() @nogc nothrow
{
	if (showAbout)
	{
		// Still draw the menu behind the About overlay.
		cast(void) mainmenu.mainMenuUpdateDraw();
		return;
	}

	auto action = mainmenu.mainMenuUpdateDraw();
	final switch (action)
	{
		case mainmenu.MenuAction.None:
			break;
		case mainmenu.MenuAction.OpenSettings:
			settingsState.origin = SettingsOrigin.MainMenu;
			currentState = AppState.Settings;
			layoutForceTriggerRefresh();
			break;
		case mainmenu.MenuAction.OpenHelp:
			help.helpReset();
			currentState = AppState.Help;
			layoutForceTriggerRefresh();
			break;
		case mainmenu.MenuAction.OpenAbout:
			showAbout = true;
			layoutForceTriggerRefresh();
			break;
		case mainmenu.MenuAction.Quit:
			wantQuit = true;
			break;
		case mainmenu.MenuAction.StartOrder5:
			beginGame(5);
			break;
		case mainmenu.MenuAction.StartOrder10:
			beginGame(10);
			break;
		case mainmenu.MenuAction.StartOrder20:
			beginGame(20);
			break;
		case mainmenu.MenuAction.StartOrderEndless:
			beginGame(-1);
			break;
	}
}

private void beginGame(int amount) @nogc nothrow
{
	mainmenu.mainMenuReset();
	gameState.gameInit(amount);
	currentState = AppState.Game;
	layoutForceTriggerRefresh();
}

private void backToMainMenu() @nogc nothrow
{
	mainmenu.mainMenuReset();
	currentState = AppState.MainMenu;
	layoutForceTriggerRefresh();
}

private void updateDrawHelp() @nogc nothrow
{
	if (help.helpUpdateDraw())
	{
		backToMainMenu();
	}
}

private void updateDrawSettingsStandalone() @nogc nothrow
{
	if (settingsState.settingsUpdateDraw())
	{
		final switch (settingsState.origin)
		{
		case SettingsOrigin.MainMenu:
			backToMainMenu();
			break;
		case SettingsOrigin.PauseMenu:
			currentState = AppState.Game;
			showPause = true;
			layoutForceTriggerRefresh();
			break;
		}
	}
}

private void updateDrawGame(float dt) @nogc nothrow
{
	if (showPause)
	{
		// Draw the frozen game frame behind, then the pause overlay.
		gameState.gameDraw();

		auto action = pauseState.pauseUpdateDraw();
		final switch (action)
		{
		case pauseState.PauseAction.None:
			break;
		case pauseState.PauseAction.Resume:
			showPause = false;
			layoutForceTriggerRefresh();
			break;
		case pauseState.PauseAction.EndSession:
			showPause = false;
			finishGameToGameOver();
			break;
		case pauseState.PauseAction.Settings:
			settingsState.origin = SettingsOrigin.PauseMenu;
			showPause = false;
			currentState = AppState.Settings;
			layoutForceTriggerRefresh();
			break;
		case pauseState.PauseAction.MainMenu:
			showPause = false;
			backToMainMenu();
			break;
		}
		return;
	}

	gameState.gameUpdate(dt);
	gameState.gameDraw();

	if (gameState.consumePauseRequested())
	{
		showPause = true;
		layoutForceTriggerRefresh();
	}

	if (gameState.consumeGameOverRequested())
		finishGameToGameOver();
}

private void finishGameToGameOver() @nogc nothrow
{
	int errors = gameState.maxLives - gameState.lives;
	gameOver.gameOverSetup(gameState.ordersCompleted, errors, gameState.orderAmount == -1);
	currentState = AppState.GameOver;
	layoutForceTriggerRefresh();
}

private void updateDrawGameOver() @nogc nothrow
{
	auto action = gameOver.gameOverUpdateDraw();
	final switch (action)
	{
		case gameOver.GameOverAction.None:
			break;
		case gameOver.GameOverAction.PlayAgain:
			beginGame(gameState.orderAmount);
			break;
		case gameOver.GameOverAction.Menu:
			backToMainMenu();
			break;
	}
}
