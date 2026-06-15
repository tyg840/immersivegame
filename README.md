# Immersive Dash

A Godot 4 rhythm platformer prototype inspired by one-button dash games.

## Prerequisites

To recreate this project and export a Windows `.exe`, install or download:

- Godot 4.6.3 for Windows, or another Godot 4.x version if you update the export preset.
- Godot export templates for the exact same Godot version.
- Windows 10 or 11.

This project was built with:

```text
Godot_v4.6.3-stable_win64.exe
Godot_v4.6.3-stable_export_templates.tpz
```

Godot expects the export templates here:

```text
C:\Users\<you>\AppData\Roaming\Godot\export_templates\4.6.3.stable
```

For this project, the Windows template files were installed at:

```text
C:\Users\trima\AppData\Roaming\Godot\export_templates\4.6.3.stable
```

The important files for Windows export are:

```text
windows_release_x86_64.exe
windows_debug_x86_64.exe
```

## Controls

- Space, Up, or W: jump
- Hold Space, Up, or W: keep jumping when you land
- R: restart

## Tuning

Basic game parameters live in:

```text
scripts\GameConfig.gd
```

Edit that file to tune values such as:

- `RUN_SPEED`
- `GRAVITY`
- `JUMP_FORCE`
- `ORB_JUMP_FORCE`
- `MAX_FALL_SPEED`
- camera start position

## Export

The Windows export preset writes to:

```powershell
build\ImmersiveDash.exe
```

From the project folder, export with:

```powershell
..\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe --path . --export-release "Windows Desktop" build\ImmersiveDash.exe
```

If you use a different Godot folder or version, replace the executable path with your local Godot console executable.
