module states.gameover;

import raylib;
import globals;
import assets;
import ui;
import save;
import core.stdc.stdio : snprintf;

private __gshared int totalOrders;
private __gshared int totalErrors;
private __gshared bool endless;
private __gshared int bestRecord;
private __gshared char[64] statsBuf;
private __gshared char[64] bestBuf;

void gameOverSetup(int orders, int errors, bool endlessMode) @nogc nothrow
{
	totalOrders = orders;
	totalErrors = errors;
	endless = endlessMode;

	snprintf(statsBuf.ptr, statsBuf.length, "Orders: %d  Errors: %d", orders, errors);

	bestRecord = loadBestScore();
	if (orders > bestRecord)
	{
		bestRecord = orders;
		saveBestScore(bestRecord);
	}
	snprintf(bestBuf.ptr, bestBuf.length, "Best Record: %d orders", bestRecord);
}

private const(char)* calculateGrade() @nogc nothrow
{
	if (totalOrders <= 0) return "F";
	int success = totalOrders - totalErrors;
	if (totalErrors == 0) return "S";
	if (totalErrors == 1) return "A";
	if (totalErrors > 1 && success == totalOrders) return "B";
	if (success >= totalOrders * 0.5) return "C";
	if (success > 0) return "D";
	return "F";
}

enum GameOverAction : int { None, PlayAgain, Menu }

GameOverAction gameOverUpdateDraw() @nogc nothrow
{
	GameOverAction result = GameOverAction.None;

	DrawRectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, Color(10, 10, 10, 230));

	Rectangle panel = Rectangle(SCREEN_WIDTH * 0.5f - 210, SCREEN_HEIGHT * 0.5f - 170, 420, 340);
	DrawRectangleRounded(panel, 0.08f, 8, Color(30, 30, 30, 255));
	DrawRectangleRoundedLines(panel, 0.08f, 8, Colors.WHITE);

	float cx = panel.x + panel.width * 0.5f;
	ui.centeredText("Game Over", fontPotta, 40, cx, panel.y + 24, Colors.WHITE);

	const(char)* gradeText = endless ? "Endless Mode" : calculateGrade();
	ui.centeredText(gradeText, fontFredoka, 32, cx, panel.y + 90, Color(255, 210, 90, 255));

	ui.centeredText(statsBuf.ptr, fontFredoka, 24, cx, panel.y + 150, Colors.WHITE);
	ui.centeredText(bestBuf.ptr, fontFredoka, 20, cx, panel.y + 190, Color(200, 200, 200, 255));

	if (ui.button(Rectangle(cx - 100, panel.y + 240, 200, 44), "Play Again", fontFredoka, 22))
		result = GameOverAction.PlayAgain;
	if (ui.button(Rectangle(cx - 100, panel.y + 290, 200, 44), "Main Menu", fontFredoka, 22))
		result = GameOverAction.Menu;

	return result;
}
