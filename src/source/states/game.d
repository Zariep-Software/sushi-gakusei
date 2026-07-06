module states.game;

import raylib;
import globals;
import assets;
import ui;
import settings = states.settings;
import core.stdc.math : sinf;

private enum PI = 3.14159265f;

enum Phase : int
{
	SpawningSushi,
	InstructionGap, // pause before showing a step
	InstructionShow, // pulsing button + playing sfx for current step
	InstructionAdvance, // waiting base_speed before next step
	PlayerTurn,
	OrderCompleteWait,
	OrderFailWait
}

private enum MAX_SEQ = 8;

__gshared
{
	Action[MAX_SEQ] sequence;
	int sequenceLen;
	int playerIndex;

	int lives;
	int maxLives = 3;
	int score;
	int ordersCompleted;
	int orderAmount = -1; // -1 = endless
	bool endlessMode;

	Phase phase;
	float phaseTimer;
	int instructionStep;

	float baseSpeed = 0.6f;

	float redFlashAlpha = 0.0f;

	// Sushi slide-in animation
	float sushiX;
	float sushiTargetX;
	float sushiAlpha;
	bool sushiExiting;
	int sushiVariant;

	// Action feedback anim
	bool animPlaying;
	Action animAction;
	float animT;
	float animDuration = 0.18f;

	// Per-action button pulse scale
	float[4] buttonScale = [1.0f, 1.0f, 1.0f, 1.0f];

	bool gameOverRequested;
	bool pauseRequested;
}

private immutable float[4] ANIM_DURATIONS = [0.30f, 0.30f, 0.45f, 0.30f]; // cut, slice, salt, vinegar

private float getSushiY() @nogc nothrow
{
	return cast(float)GetScreenHeight() - 256.0f;
}

private float lerp(float a, float b, float t) @nogc nothrow
{
	return a + (b - a) * t;
}

private Rectangle[4] actionButtonRects() @nogc nothrow
{
	float sw = cast(float)GetScreenWidth();
	float sh = cast(float)GetScreenHeight();

	float w = 110, h = 110, gap = 24;
	float totalW = w * 4 + gap * 3;
	float x0 = (sw - totalW) * 0.5f;
	float y = sh - h - 24;
	Rectangle[4] r;
	foreach (i; 0 .. 4)
		r[i] = Rectangle(x0 + i * (w + gap), y, w, h);
	return r;
}

void gameInit(int amount) @nogc nothrow
{
	orderAmount = amount;
	endlessMode = amount == -1;
	lives = maxLives;
	score = 0;
	ordersCompleted = 0;
	redFlashAlpha = 0.0f;
	sequenceLen = 3;
	gameOverRequested = false;
	pauseRequested = false;
	startNewOrder();
}

private void startNewOrder() @nogc nothrow
{
	playerIndex = 0;
	foreach (i; 0 .. sequenceLen)
		sequence[i] = cast(Action) GetRandomValue(0, 3);

	sushiVariant = GetRandomValue(0, 3);
	spawnSushi();

	phase = Phase.InstructionGap;
	phaseTimer = 0.5f;
	instructionStep = 0;
}

private void spawnSushi() @nogc nothrow
{
	float sw = cast(float)GetScreenWidth();
	sushiTargetX = sw * 0.5f - 64;
	sushiX = sushiTargetX - 300;
	sushiAlpha = 0.0f;
	sushiExiting = false;
}

private void exitSushi() @nogc nothrow
{
	sushiExiting = true;
}

void gameUpdate(float dt) @nogc nothrow
{
	updateActionButtons(dt);

	if (redFlashAlpha > 0)
		redFlashAlpha = redFlashAlpha - dt * 2.0f > 0 ? redFlashAlpha - dt * 2.0f : 0.0f;

	// Sushi slide-in
	if (!sushiExiting && sushiAlpha < 1.0f)
	{
		sushiAlpha += dt / 0.5f;
		if (sushiAlpha > 1.0f) sushiAlpha = 1.0f;
		sushiX += (sushiTargetX - sushiX) * dt * 6.0f;
	}
	if (sushiExiting)
	{
		sushiX += dt * 500.0f;
		sushiAlpha -= dt / 0.5f;
		if (sushiAlpha < 0) sushiAlpha = 0;
	}

	if (animPlaying)
	{
		animT += dt;
		if (animT >= animDuration)
			animPlaying = false;
	}

	final switch (phase)
	{
		case Phase.SpawningSushi:
			phase = Phase.InstructionGap;
			phaseTimer = 0.5f;
			break;

		case Phase.InstructionGap:
			phaseTimer -= dt;
			if (phaseTimer <= 0)
			{
				phase = Phase.InstructionShow;
				phaseTimer = 0.2f;
				playInstructionFeedback(sequence[instructionStep]);
			}
			break;

		case Phase.InstructionShow:
			phaseTimer -= dt;
			if (phaseTimer <= 0)
			{
				phase = Phase.InstructionAdvance;
				phaseTimer = baseSpeed;
			}
			break;

		case Phase.InstructionAdvance:
			phaseTimer -= dt;
			if (phaseTimer <= 0)
			{
				instructionStep++;
				if (instructionStep >= sequenceLen)
				{
					phase = Phase.PlayerTurn;
				}
				else
				{
					phase = Phase.InstructionShow;
					phaseTimer = 0.2f;
					playInstructionFeedback(sequence[instructionStep]);
				}
			}
			break;

		case Phase.PlayerTurn:
			handlePlayerInput();
			break;

		case Phase.OrderCompleteWait:
			phaseTimer -= dt;
			if (phaseTimer <= 0)
			{
				if (sequenceLen < MAX_SEQ) sequenceLen++;
				startNewOrder();
			}
			break;

		case Phase.OrderFailWait:
			phaseTimer -= dt;
			if (phaseTimer <= 0)
			{
				if (lives <= 0)
					gameOverRequested = true;
				else
					startNewOrder();
			}
			break;
	}
}

private ui.ButtonInteraction[4] buttonInteract;
private Color[4] buttonTint = [DIM, DIM, DIM, DIM];

private immutable Color DIM = Color(120, 120, 120, 255);
private immutable Color HOVER = Color(220, 220, 220, 255);
private immutable Color ACTIVE = Colors.WHITE;

private void updateActionButtons(float dt) @nogc nothrow
{
	Rectangle[4] rects = actionButtonRects();
	bool instructionActive = phase == Phase.InstructionShow;

	bool ignoreHover = false;
	version(Android) { ignoreHover = true; }

	if (GetTouchPointCount() > 0)
	{
		ignoreHover = true;
	}

	foreach (i; 0 .. 4)
	{
		Action a = cast(Action) i;
		buttonInteract[i] = ui.iconButtonInteract(rects[i]);

		bool isInstruction = instructionActive && sequence[instructionStep] == a;
		float target;

		if (isInstruction)
		{
			target = 1.2f;
			buttonTint[i] = ACTIVE;
		}
		else if (buttonInteract[i].down)
		{
			target = 1.2f;
			buttonTint[i] = HOVER;
		}
		else if (!ignoreHover && buttonInteract[i].hovered)
		{
			target = 1.0f;
			buttonTint[i] = HOVER;
		}
		else
		{
			target = 1.0f;
			buttonTint[i] = DIM;
		}

		buttonScale[i] += (target - buttonScale[i]) * (dt * 12.0f);
	}
}

private void playInstructionFeedback(Action a) @nogc nothrow
{
	PlaySound(*actionSound(a));
}

private void handlePlayerInput() @nogc nothrow
{
	Action pressed;
	bool got = false;

	KeyboardKey kCut = settings.keyFor(0);
	KeyboardKey kSlice = settings.keyFor(1);
	KeyboardKey kSalt = settings.keyFor(2);
	KeyboardKey kVinegar = settings.keyFor(3);

	if (IsKeyPressed(kCut)) { pressed = Action.CUT; got = true; }
	else if (IsKeyPressed(kSlice)) { pressed = Action.SLICE; got = true; }
	else if (IsKeyPressed(kSalt)) { pressed = Action.SALT; got = true; }
	else if (IsKeyPressed(kVinegar)) { pressed = Action.VINEGAR; got = true; }

	if (!got)
	{
		foreach (i; 0 .. 4)
		{
			if (buttonInteract[i].released)
			{
				pressed = cast(Action) i;
				got = true;
				break;
			}
		}
	}

	if (IsKeyPressed(settings.keyFor(4)) || IsKeyPressed(KeyboardKey.KEY_ESCAPE))
		pauseRequested = true;

	if (!got) return;

	PlaySound(*actionSound(pressed));
	triggerAnim(pressed);

	if (pressed == sequence[playerIndex])
	{
		playerIndex++;
		if (playerIndex >= sequenceLen)
			completeOrder();
	}
	else
	{
		failOrder();
	}
}

private void triggerAnim(Action a) @nogc nothrow
{
	animPlaying = true;
	animAction = a;
	animT = 0.0f;
	animDuration = ANIM_DURATIONS[a];
}

private void completeOrder() @nogc nothrow
{
	score += 100;
	ordersCompleted++;
	PlaySound(sfxDone);

	if (orderAmount != -1 && ordersCompleted >= orderAmount)
	{
		gameOverRequested = true;
		return;
	}

	exitSushi();
	phase = Phase.OrderCompleteWait;
	phaseTimer = 1.5f;
}

private void failOrder() @nogc nothrow
{
	lives--;
	redFlashAlpha = 0.7f;
	PlaySound(sfxWrong);

	exitSushi();
	phase = Phase.OrderFailWait;
	phaseTimer = 1.5f;
}

// Drawing //

void gameDraw() @nogc nothrow
{
	float sw = cast(float)GetScreenWidth();
	float sh = cast(float)GetScreenHeight();
	float currentSushiY = getSushiY();

	ui.drawAspectCover(texBackground, Rectangle(0, 0, sw, sh), Colors.WHITE);

	Rectangle workbenchRect = Rectangle(sw * 0.5f - 725, sh - 400, 1450, 714);
	DrawTexturePro(texWorkbench,
		Rectangle(0, 0, cast(float) texWorkbench.width, cast(float) texWorkbench.height),
		workbenchRect, Vector2(0, 0), 0.0f, Colors.WHITE);

	// Sushi
	if (sushiAlpha > 0.001f)
	{
		Texture2D sushi = texSushi[sushiVariant];
		Rectangle dst = Rectangle(sushiX, currentSushiY, 128, 128);
		DrawTexturePro(sushi, Rectangle(0, 0, cast(float) sushi.width, cast(float) sushi.height),
			dst, Vector2(0, 0), 0.0f, Color(255, 255, 255, cast(ubyte)(sushiAlpha * 255)));
	}

	// Action feedback anim: relative to the sushi's current position
	if (animPlaying)
	{
		Texture2D t = *actionAnim(animAction);
		float progress = animT / animDuration;
		if (progress > 1.0f) progress = 1.0f;

		Vector2 sushiCenter = Vector2(sushiX + 96.0f, currentSushiY + 32.0f);
		Vector2 offset = Vector2(0.0f, 0.0f);
		float rotation = 0.0f;

		final switch (animAction)
		{
			case Action.CUT:
				// Top to bottom
				offset.y = lerp(-70.0f, 70.0f, progress);
				break;

			case Action.SLICE:
				// Left to right
				offset.x = lerp(-70.0f, 70.0f, progress);
				break;

			case Action.SALT:
				// oscillate +-15 degrees several times
				rotation = sinf(progress * PI * 4.0f) * 15.0f;
				break;

			case Action.VINEGAR:
				// swing to +30 degrees and back, just once
				rotation = progress < 0.5f
					? lerp(0.0f, 30.0f, progress * 2.0f)
					: lerp(30.0f, 0.0f, (progress - 0.5f) * 2.0f);
				break;
		}

		Rectangle bounds = Rectangle(sushiCenter.x + offset.x - 64.0f, sushiCenter.y + offset.y - 64.0f, 128.0f, 128.0f);
		Rectangle dst = ui.aspectFitRect(t, bounds);
		Vector2 origin = Vector2(dst.width * 0.5f, dst.height * 0.5f);
		Rectangle rotDst = Rectangle(dst.x + origin.x, dst.y + origin.y, dst.width, dst.height);
		DrawTexturePro(t, Rectangle(0, 0, cast(float) t.width, cast(float) t.height), rotDst, origin, rotation, Colors.WHITE);
	}

	drawActionButtons();
	drawHud();

	if (redFlashAlpha > 0.001f)
		DrawRectangle(0, 0, cast(int)sw, cast(int)sh, Color(255, 0, 0, cast(ubyte)(redFlashAlpha * 255)));
}

private void drawActionButtons() @nogc nothrow
{
	Rectangle[4] rects = actionButtonRects();
	foreach (i; 0 .. 4)
		ui.drawIconScaled(rects[i], *actionIcon(cast(Action) i), buttonTint[i], buttonScale[i]);
}

private void drawHud() @nogc nothrow
{
	float sw = cast(float)GetScreenWidth();

	DrawTextEx(fontFredoka, TextFormat("Score: %d", score), Vector2(20, 20), 28, 1.0f, Colors.WHITE);
	DrawTextEx(fontFredoka, TextFormat("Lives: %d", lives), Vector2(20, 54), 28, 1.0f, Colors.WHITE);

	Rectangle pauseRect = Rectangle(sw - 70, 8, 64, 64);
	if (ui.iconButton(pauseRect, texUiPause, false))
	{
		pauseRequested = true;
	}
}

bool consumeGameOverRequested() @nogc nothrow
{
	bool v = gameOverRequested;
	gameOverRequested = false;
	return v;
}

bool consumePauseRequested() @nogc nothrow
{
	bool v = pauseRequested;
	pauseRequested = false;
	return v;
}
