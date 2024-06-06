# SCP Scripts for Garry's Mod RP Servers

## Introduction
This repository contains two scripts for Garry's Mod servers related to SCP (Secure, Contain, Protect) gameplay. The scripts enable SCP role players to trigger various actions, including changing codes and initiating breaches.

## SCP Codes Script

### Features
- Allows SCP role players to change codes using chat commands.
- Sends HUD updates and plays sounds for all players when codes are changed.
- Customizable code commands, text, colors, and sounds.

### Installation
1. Ensure you have Garry's Mod installed on your server.
2. Download or clone this repository.
3. Place the `scp_codes.lua` script in your server's `garrysmod/lua/autorun/` directory.
4. Restart your server or execute the script manually to load it.

### Usage
- SCP role players can use chat commands (e.g., `/cdgreen`, `/cdyellow`, `/cdorange`, `/cdred`, `/cdblack`) to change codes.
- Code commands, text, colors, and sounds can be customized in the script file (`scp_codes.lua`).

## SCP Breach Script

### Features
- Initiate breaches for different SCP roles.
- Customizable breach positions and timers for each SCP role.
- Cooldown periods to prevent frequent breaches.
- Ability to stop ongoing breaches.
- Player notifications for breach events.

### Installation
1. Ensure you have Garry's Mod installed on your server.
2. Download or clone this repository.
3. Place the `scp_breach.lua` script in your server's `garrysmod/lua/autorun/` directory.
4. Restart your server or execute the script manually to load it.

### Usage
- As a player assigned to an SCP role, use the `/breach` command to initiate a breach.
- Use the `/stopbreach` command to stop an ongoing breach.
- Breach positions and cooldown times can be customized in the script file (`scp_breach.lua`).

## License
These projects are licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author
- ItsCentu (GitHub: [ItsCentu](https://github.com/ItsCentu))

## Acknowledgments
Special thanks to the Garry's Mod community for their support and contributions.

