# PlasmaCutterDurability

A Palworld Lua mod that increases the Plasma Multicutter's maximum durability and can refill its current durability while equipped.

## Features

- Raise the tool's maximum durability above the vanilla value of `850`.
- Refill current durability to its maximum on a configurable interval.
- Choose an absolute maximum or calculate it using a multiplier.
- Restrict the changes to the equipped tool or search all supported inventory slots.
- Enable optional diagnostic logging.

## Requirements

- Palworld for PC.
- A Lua mod loader that supports the scripts and Palworld APIs used by this mod.

## Installation

Install `main.lua` and `config.lua` from the repository's `Scripts/` directory into the mod's `Scripts/` directory used by your Palworld Lua mod loader. Edit `config.lua` if needed, then restart the game or reload the mod.

## Configuration

Settings are in `Scripts/config.lua`.

| Setting | Default | Description |
|---|---:|---|
| `ENABLED` | `true` | Enable or disable the mod. |
| `DEBUG` | `false` | Print detailed `[PlasmaCutterDurability]` logs. |
| `TOOL_STATIC_ID` | `LaserMiningTool` | Internal static ID of the Plasma Multicutter. |
| `TARGET_MAX_DURABILITY` | `8500` | Absolute maximum; when greater than `0`, overrides the multiplier. |
| `DURABILITY_MULTIPLIER` | `10` | Multiplier used when `TARGET_MAX_DURABILITY` is `0`. |
| `VANILLA_MAX_DURABILITY` | `850` | Vanilla maximum used by the multiplier. |
| `INFINITE_DURABILITY` | `true` | Keep current durability topped up to the maximum. |
| `CHECK_INTERVAL_MS` | `2000` | Durability check interval in milliseconds. |
| `BOOTSTRAP_DELAY_MS` | `3000` | Delay before the mod starts checking the tool. |
| `ONLY_EQUIPPED` | `true` | Only affect the tool while it is equipped. |

## Compatibility

The mod accesses Palworld's internal item and inventory APIs. Game updates that change those APIs may require a mod update. Set `ENABLED = false` to disable its behavior.

## Development

The repository contains the Lua scripts directly and has no build step. Keep the setting names in `Scripts/config.lua` consistent with the values read by `Scripts/main.lua`.

## Links

- [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3778065447)

## License

No license file is included in this repository.
