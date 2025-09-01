## v0.1.1 - 2025-09-01

### Added
- **In-Game Options Panel** – Available under `Interface → AddOns`, allowing users to manage commands directly in-game.
- **Configurable Commands** – Add, edit, and remove custom commands via the options panel. Commands are saved across game sessions.
- **Dedicated Options File** – Introduced `SimpleDevTools_Options.lua` to handle configuration panel logic and UI, separated from the core addon.
- **Right-Click Functionality** – Right-clicking the LDB icon now opens the options panel.
- **Saved Variables** – Added `SimpleDevToolsDB` for storing both built-in and user-defined commands.

### Changed
- **Dynamic Menu Generation** – The command menu is now generated from saved variables, reflecting user configuration instead of being hardcoded.
- **Tooltip Update** – Now clearly indicates that **Left-click** opens the menu and **Right-click** opens the configuration panel.

### Fixed
- **Static Command List** – The menu was previously fixed and non-customizable. It now fully supports user-defined commands for maximum flexibility.

## v0.0.1 - 2025-08-19

Initial commit
