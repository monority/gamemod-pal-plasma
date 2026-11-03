# PlasmaCutterDurability

A Lua plugin for **Palworld** that raises the Plasma Multicutter's maximum durability (the *Resistance* value in-game) and keeps topping up its current durability.

## Features

- Raises max durability from the vanilla `850` to a custom target.
- Continuously refills current durability up to the new max.
- Optional infinite durability mode (`INFINITE_DURABILITY`).
- Patches both static inventory data and the dynamic equipped slot.

## Installation

1. Place the files in your project's `Scripts/` folder.
2. Open `Scripts/config.lua` and tweak the settings.
3. Restart the game (or reload the plugin).

## Configuration (`Scripts/config.lua`)

| Setting | Default | Description |
|---|---|---|
| `ENABLED` | `true` | Enables/disables the plugin. |
| `TARGET_MAX_DURABILITY` | `8500` | Absolute target max durability (overrides the multiplier). |
| `DURABILITY_MULTIPLIER` | `10` | Used when `TARGET_MAX_DURABILITY = 0`: `850 × 10 = 8500`. |
| `VANILLA_MAX_DURABILITY` | `850` | Vanilla max durability. |
| `INFINITE_DURABILITY` | `true` | Refills current durability up to the max. |
| `CHECK_INTERVAL_MS` | `2000` | Polling interval in milliseconds. |
| `ONLY_EQUIPPED` | `true` | Only affects the tool while it is equipped. |
| `DEBUG` | `false` | Prints detailed `[PlasmaCutterDurability]` logs. |

## Steam

- **Steam shared file :** https://steamcommunity.com/sharedfiles/filedetails/?id=3778065447
