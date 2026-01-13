# 🧊 SmartCube

**Codawatt — EGC Project**

SmartCube is a grid-based puzzle platformer made in **Godot 4**.
The player moves a cube across tiles, interacts with numbers, coins and power-ups, and must reduce all number tiles to **zero** before the rising **lava** reaches them.

---

## 🎮 Game Rules

* The level is a grid of tiles.
* **Number tiles** must be reduced to `0`.
* Each time the player stands on a number tile, its value decreases.
* Some number tiles are **locked** and require **coins** to unlock.
* **Power-ups** modify all remaining number tiles.
* **Lava** starts rising after the first move.
* You win when all numbers reach `0`.
* You lose if the lava touches the player.

---

## 🗂 Project Structure

```
scenes/
│
├── player.gd
├── number_square.tscn
├── floor.tscn
├── coin.tscn
└── power_up.tscn
└── levels/
    └── level.gd
```
---

## 🧠 Main Scripts

### `scenes/levels/level.gd`

**The game controller**

This script builds the level from data and controls all gameplay logic.

Main responsibilities:

* Spawns all objects from `LevelData`
* Manages:

  * numbers
  * platforms
  * coins
  * power-ups
  * player
* Tracks the total sum of all number tiles
* Starts and controls lava
* Checks win / lose conditions

Key features:

* `number_sum` → total of all number tiles
* `number_dict` → maps grid positions to NumberSquare objects
* Handles:

  * player movement requests
  * collisions
  * falling
  * number subtraction
  * power-ups

Important functions:

* `_generate_map_from_resource()` – builds the whole level
* `_on_player_wish_move()` – decides where the player can move
* `_on_check_player_ground()` – handles falling and number subtraction
* `_apply_power_up()` – modifies all numbers at once

---

### `scenes/game/player.gd`

**The player controller**

This script handles player input, movement and animations.

Main responsibilities:

* Reads keyboard and mobile UI input
* Sends move requests to `Level`
* Animates movement using tweens
* Handles falling and jumping logic

Movement system:
The player does not move directly.
Instead it asks the `Level` what to do:

```
Player → wish_move → Level → player_next_position → Player moves
```

Movement types:

* **0 – Parabolic** (jumping)
* **1 – Linear** (falling)
* **2 – Step + Jump** (climb over a block)

Important functions:

* `_buffer_move()` – stores player input
* `_on_main_player_next_position()` – receives final target position
* `move_parabolic()` – jump arc
* `move_linear()` – straight movement
* `_move_strategy()` – selects the movement style

---

## 🔄 How Player Movement Works

1. Player presses left or right
2. `Player` emits `wish_move(position, direction)`
3. `Level` checks:

   * walls
   * platforms
   * numbers
   * coins
   * power-ups
4. `Level` sends back:

   * new position
   * movement strategy
5. `Player` animates the movement
6. After moving, ground is checked for numbers or falling

---

## 🧪 Debug Controls

In `level.gd`:

* `debug_add` → add to all numbers
* `debug_subtract` → subtract from all numbers
* `restart` → restart level

---

## 🏁 Win & Lose

* **Win** → all numbers reach `0`
* **Lose** → lava touches the player

---

## 🛠 Built With

* **Godot 4**
* GDScript

---
