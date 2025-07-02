# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Audio device switcher script using Babashka (Clojure) and wpctl (WirePlumber). Toggles between Built-in Audio and SteelSeries Arctis 7 Game audio devices.

## Architecture

- `audio-switcher.clj`: Main Clojure script that queries wpctl status, parses output, and switches between predefined audio devices
- `flake.nix`: Nix flake providing packaging, development environment, and NixOS module
- `bb.edn`: Babashka configuration (currently empty)

## Development Commands

**Run script directly:**
```bash
bb audio-switcher.clj
```

**Nix development:**
```bash
nix develop              # Enter dev shell with babashka and wireplumber
nix run                  # Run the packaged script
nix build                # Build the package
```

**Testing the script:**
```bash
wpctl status             # Check current audio status
bb audio-switcher.clj    # Run the switcher
wpctl status             # Verify the switch occurred
```

## Code Structure

The script follows a functional approach:
1. Calls `wpctl status` once and stores output
2. Parses current device from stored output
3. Determines target device (toggles between two hardcoded devices)
4. Extracts sink ID for target device
5. Executes `wpctl set-default` if valid ID found

Device names are hardcoded: "Built-in Audio Analog Stereo" and "SteelSeries Arctis 7 Game".