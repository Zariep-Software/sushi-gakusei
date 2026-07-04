module save;

import core.stdc.stdio;
import globals;

struct SettingsData
{
	bool fullscreen = false;
	int resolutionIndex = -1;
	float feedbackVolume = 1.0f;
	float actionsVolume = 1.0f;
	float musicVolume = 1.0f;
}

int loadBestScore() @nogc nothrow
{
	FILE* f = fopen(SAVE_FILE, "rb");
	if (f is null) return 0;
	int value = 0;
	fread(&value, int.sizeof, 1, f);
	fclose(f);
	return value;
}

void saveBestScore(int value) @nogc nothrow
{
	FILE* f = fopen(SAVE_FILE, "wb");
	if (f is null) return;
	fwrite(&value, int.sizeof, 1, f);
	fclose(f);
}

SettingsData loadSettings() @nogc nothrow
{
	SettingsData s;
	FILE* f = fopen(SETTINGS_FILE, "rb");
	if (f is null) return s;
	fread(&s, SettingsData.sizeof, 1, f);
	fclose(f);
	return s;
}

void saveSettings(ref SettingsData s) @nogc nothrow
{
	FILE* f = fopen(SETTINGS_FILE, "wb");
	if (f is null) return;
	fwrite(&s, SettingsData.sizeof, 1, f);
	fclose(f);
}
