# Core Mechanic

### Instruction Phase

A sequence of cooking actions plays.

Example:

1. CUT
2. SLICE
3. VINEGAR 
4. SALT


Each action has:

- sound cue
- quick icon flash

Timing example:

1. sound
2. 0.6 sec pause
3. next sound

Later levels:

1. sound
2. 0.3 sec pause

### Player Input Phase

Player repeats the sequence.

Keyboard example:

| Action | Key | Sound |
| --- | --- | --- |
| Cut | C/U | chop sound |
| Slice | X/I | slicing sound |
| Salt | S/O | sprinkle sound |
| Vinegar | V/P | liquid pour |


If the sequence matches success.


# Actions

| Action | Description |
| --- | --- |
| Cut | Chop ingredient |
| Slice | Thin sushi slice |
| Salt | Season |
| Vinegar | Pour rice vinegar |


Total possible combinations:

```
4^sequence_length
```

#  Audio

Sounds should be **very distinct**.

| Action | Sound idea |
| --- | --- |
| Cut | single knife chop |
| Slice | fast blade slide |
| Salt | shaker sprinkle |
| Vinegar | liquid pour |

Sound recognition is the core gameplay, so clarity matters.

# Difficulty Progression

Increase difficulty using speed + sequence length.

Example progression:

| Order | Sequence Length | Speed |
| --- | --- | --- |
| 1–3 | 3 | slow |
| 4–7 | 4 | normal |
| 8–12 | 5 | fast |
| 13+ | 6 | faster |


Endless mode simply continues increasing speed.

# Game Modes

### Arcade Mode

Player chooses:

- 10 orders
- 20 orders
- 30 orders

Win by completing all orders and gets a score.


### Endless Mode

Orders continue forever.

Score increases per completed order.

Goal: highest score before losing all lives.


#  Player State

Lives: `3`

Lose a life if wrong key is pressed

Game Over when lives reach 0.

Endless mode shows **high score**.

