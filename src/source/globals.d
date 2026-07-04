module globals;

enum SCREEN_WIDTH = 1280;
enum SCREEN_HEIGHT = 720;
enum TARGET_FPS = 60;

// Actions the player can perform
enum Action : int
{
	CUT = 0,
	SLICE = 1,
	SALT = 2,
	VINEGAR = 3
}

// Which top level screen/state is currently active
enum AppState : int
{
	MainMenu,
	ModeSelect,
	Help,
	Settings,
	Game,
	GameOver,
	About
}

// Where user came from when opening Settings
enum SettingsOrigin : int
{
	MainMenu,
	PauseMenu
}

enum ASSET_IMG = "assets/img/";
enum ASSET_SFX = "assets/sfx/";
enum ASSET_MUSIC = "assets/music/";
enum ASSET_FONTS = "assets/fonts/";

enum FONT_FREDOKA = ASSET_FONTS ~ "Fredoka/static/Fredoka-Regular.ttf";
enum FONT_POTTA = ASSET_FONTS ~ "Potta_One/PottaOne-Regular.ttf";

enum SAVE_FILE = "save.dat";
enum SETTINGS_FILE = "settings.cfg";
