# Magnify v3.0.3

Magnify is a legacy World of Warcraft 1.12 add-on that increases the available zoom levels on the world map. This fork includes updates for better compatibility with Shagutweaks and LevelRange.
Includes coordinates on World map frame.

- Repository: paokkerkir/Magnify
- Language: Lua
- Version: 3.0.3
- Last updated: 2026-03-21

## Overview

Magnify extends the default world map zoom so that players can zoom in closer than the stock client allows. It targets Vanilla clients (WoW 1.12) and is intended for players who want a closer view of map details.

## Compatibility

- Tested with World of Warcraft 1.12 (Vanilla)
- Updated for improved compatibility with:
  - Shagutweaks
  - LevelRange

## Installation

Manual installation:
1. Download the repository as a ZIP
2. Copy the `Magnify` folder into your World of Warcraft `Interface/AddOns/` directory.
   - The final path should look like: `.../World of Warcraft/Interface/AddOns/Magnify/`
3. Start (or restart) the WoW client.
4. Ensure the add-on is enabled in the AddOns list on the character screen.

If you use any addon manager that supports vanilla addons, you can install the folder there instead.

## Usage

Once installed and enabled, Magnify increases the map zoom range. Open the world map (default hotkey `M`) to access the extended zoom. There is no required configuration for basic use.

If you rely on other UI mods, ensure Magnify loads in a compatible order or that any conflicting map UI hooks are adjusted.

## Configuration

This add-on contains no runtime configuration.

## Troubleshooting

- If the add-on does not appear in the AddOns list:
  - Verify the folder name is `Magnify` and it resides directly inside `Interface/AddOns/`.
- If behavior conflicts with other map-related addons (e.g., Shagutweaks or LevelRange), try:
  - Reordering load order so Magnify loads after the other addon, or
  - Disabling one addon to isolate the conflict.
- Check the client Lua error log for messages if the addon fails to load.

## License

MIT License

## Credits

- Original Magnify author: lookino
- Maintainer of this fork: paokkerkir

## Support

Open an issue in this repository with clear reproduction steps and the client environment (WoW version, list of enabled addons) if you encounter problems.
