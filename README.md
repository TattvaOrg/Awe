# Awe

- Awe is a curated collection of standalone, interactive Material 3 desktop widgets built with [Quickshell](https://quickshell.outfoxxed.me/) for Linux and Wayland compositors.

- Each widget is an independent QML component that can be moved, scaled, customized, and toggled across your desktop with persistent configuration.

https://github.com/user-attachments/assets/30c044ea-ceda-4a61-8733-acd02f01f31c

## All Widgets
<img width="1361" height="761" alt="all" src="https://github.com/user-attachments/assets/0337ce98-14df-4df8-b627-9ef1f8767197" />

## Desktop example
<img width="1366" height="768" alt="ex" src="https://github.com/user-attachments/assets/da42bec0-81c4-48a7-93f9-1ed526418a66" />

---

## Features

- **Material 3 Expressive Design**: Tonal elevation palettes, organic shapes, and responsive interaction states.
- **Wayland Native**: Optimized for `WlrLayershell` with precise input region masking for wallpaper click-through.
- **Independent Dragging & Scaling**: Every widget can be repositioned via mouse drag and resized using the mouse scroll wheel.
- **State Persistence**: Positions, scale factors, custom notes, timezones, habits, and visibility states automatically save to `~/.config/quickshell/widget_settings.json`.
- **Top Dynamic Notch / Widget Manager**: Floating top bar to toggle visibility for individual widgets in real time with smooth scrolling.

---

## Widget Suite Overview

### Core & Productivity
- **NotesWidget (`NotesWidget.qml`)**: Google Keep-style note pad with instant inline text editing, debounced auto-saving, multi-note navigation, and Material 3 color themes.
- **TodoWidget (`TodoWidget.qml`)**: Interactive task checklist with completion tracking and progress indicator.
- **HabitsWidget (`HabitsWidget.qml`)**: 7-day habit streak tracker with interactive daily check matrix and habit creation prompt.
- **CalcWidget (`CalcWidget.qml`)**: Minimalist floating calculator with expression evaluation, live results, and Material 3 keypad.
- **ClipboardWidget (`ClipboardWidget.qml`)**: Real-time clipboard history monitor using `wl-paste` with one-click copying (`wl-copy`).
- **TimerWidget (`TimerWidget.qml`)**: Pomodoro focus timer, break countdown, stopwatch, and custom duration stepper adjustments (`+1m`, `-1m`, `+5m`).

### Media & Visuals
- **VisualizerWidget (`VisualizerWidget.qml`)**: Live desktop audio spectrum with 3 interactive modes: 16-Bar Spectrum Equalizer, Fluid Sine Waveform, and Radial Soundwave.
- **MediaWidget (`MediaWidget.qml`)**: MPRIS media player featuring an Android 14/15 squiggly waveform seekbar, animated soundwave equalizer bars, playback controls, and active player indicator.
- **PosterWidget (`PosterWidget.qml`)**: Organic Material 3 photo frame (Arch, Scallop, Squircle, Pebble, Heart, Flower, Stadium) with animated GIF playback support and right-click native file picker.
- **QuoteWidget (`QuoteWidget.qml`)**: Rotating daily inspiration card with author tags and refresh shuffle.

### System & Telemetry
- **ResourceWheelWidget (`ResourceWheelWidget.qml`)**: 4 concentric circular progress arcs displaying real-time CPU, RAM, Disk, and Temperature telemetry.
- **StorageMapWidget (`StorageMapWidget.qml`)**: Segmented disk storage visualizer showing Root partition usage, free space, and disk capacity.
- **ThermalWidget (`ThermalWidget.qml`)**: Hardware temperature monitor showing CPU package and core temperatures with thermal status indicators.
- **SystemInfo (`SystemInfo.qml`)**: Clean overview of CPU load, memory utilization, and storage capacity.
- **BatteryWidget (`BatteryWidget.qml`)**: Battery charge level, AC adapter status, and power metrics.
- **VolumeBrightnessWidget (`VolumeBrightnessWidget.qml`)**: PipeWire (`wpctl`) volume pill slider with mute toggle and display backlight (`brightnessctl`) slider.

### Network, Developer & Clocks
- **PingWidget (`PingWidget.qml`)**: Live network latency monitor pinging Cloudflare (1.1.1.1), Google DNS, and GitHub with real-time jitter graph.
- **NetworkWidget (`NetworkWidget.qml`)**: Live Wi-Fi SSID, bandwidth upload/download meters, activity sparklines, and double-click IP address privacy mask.
- **CryptoWidget (`CryptoWidget.qml`)**: Live market prices for Bitcoin (BTC), Ethereum (ETH), and Solana (SOL) with 24h change pills and trend sparklines.
- **GitDashboardWidget (`GitDashboardWidget.qml`)**: Repository workspace monitor showing active branch, uncommitted diff counter, and last commit summary.
- **WorldClockWidget (`WorldClockWidget.qml`)**: Multi-city timezone hub with solar day/night indicators, double-click UI shape cycling (4 layouts), and custom UTC offset addition.
- **Clock (`Clock.qml`)**: Versatile desktop clock supporting Cookie, Nothing OS, Android stacked, and digital typographic styles.
- **CalendarWidget (`CalendarWidget.qml`)**: Interactive monthly calendar with date selection grid.

---

## Installation & Requirements

### Dependencies
Ensure the following packages are installed on your Linux system:

- **Quickshell** (0.3.0 or newer)
- **Qt 6 Declarative / Quick / Effects** (`qt6-declarative`, `qt6-quicktimeline`)
- **Python 3** with `PyGObject` (`python-gobject`, GTK 3.0)
- **playerctl** (for MPRIS media control)
- **brightnessctl** (for backlight control)
- **pipewire / wireplumber** (`wpctl` for audio)
- **wl-clipboard** (`wl-paste` and `wl-copy` for clipboard history)
- **lm_sensors** (for hardware thermals)
- **curl** (for crypto and weather updates)
- **iputils** (for network ping latency)

### Launching & Setup

Clone this repository into your Quickshell configuration directory:

```bash
git clone https://github.com/AbsolOrg/Awe.git ~/.config/quickshell/Awe
cd ~/.config/quickshell/Awe
./install.sh
```

Run `awe` in your terminal to open the rich Settings Panel, or start the desktop widgets immediately:

```bash
# Launch the rich black Settings GUI panel
awe

# Start desktop widgets in the background
awe start
```

---

## Awe CLI & Rich Settings Panel

Awe comes with a native executable CLI companion and a dedicated luxury dark Settings Control Center:

- **Rich Dark Settings Panel (`awe` or `awe gui`)**:
  - **Themes & Aesthetics**: Visual gallery and one-click switcher featuring **System Dynamic** (automatic Material 3 palette extraction from active desktop wallpaper via Matugen) along with 10 handcrafted presets (*Liquid Glass*, *Transparent*, *Material 3*, *Cyberpunk*, *Nordic Frost*, *OLED Black*, *Warm Latte*, *Tokyo Night*, *Evergreen*, and *Aurora Prism*). The settings panel itself remains in a fixed, unified luxury obsidian black theme.
  - **Widget Manager**: Enable / disable toggles for all 24 widgets with real-time reactive desktop updates and search filtering. Widgets can also be toggled directly from the expanded desktop pill.
  - **Awe Toggle Pill**: Configure screen position (top center, top left, top right, bottom center, bottom left, bottom right), custom label text, and visibility toggle.
  - **Widget Tweaks**: Per-widget customizations (Clock styles, Poster frame shapes, Visualizer modes, Crypto coins, Network IP masking).
  - **Layout & Scaling**: Global scaling slider (0.5x – 1.5x) and one-click factory layout reset.
  - **Daemon & Startup**: Process supervisor (Start, Stop, Restart Awe) and toggle autostart on desktop login.

- **CLI Commands**:

```bash
awe                          # Open rich Settings GUI panel
awe start                    # Start desktop widgets in background
awe stop                     # Stop running desktop widgets
awe restart                  # Restart Awe desktop widgets
awe status                   # Show status, active theme, and enabled widgets
awe theme [name]             # View or switch active theme (e.g. awe theme system, awe theme cyberpunk)
awe wallpaper-sync [path]    # Extract Material 3 colors from wallpaper via Matugen
awe list                     # List all 24 widgets and visibility states
awe toggle <widget>          # Toggle a widget on/off (e.g. awe toggle clock)
awe enable <widget>          # Enable a widget explicitly
awe disable <widget>         # Disable a widget explicitly
awe pill [pos]               # Set desktop pill position (top_center, bottom_center, etc.)
awe pill-text [text]         # Set custom text on desktop pill (e.g. awe pill-text "✦ Widgets")
awe pill-toggle              # Show or hide desktop pill completely
awe scale <value>            # Adjust master scale factor (e.g. awe scale 0.85)
awe autostart [on|off]       # Toggle autostart on user login
awe install                  # Symlink awe to ~/.local/bin/awe and install desktop entry
awe uninstall                # Remove awe binary symlink and desktop entry
```

---

## Configuration

Widget positions, scale factors, theme palettes, and visibility states are stored automatically in:

```
~/.config/quickshell/widget_settings.json
```

---

## Credits & Acknowledgments

Awe is built upon and inspired by phenomenal open-source projects across the Linux desktop ecosystem:

- **[Matugen](https://github.com/InioX/matugen)** by [InioX](https://github.com/InioX) — High-performance Material You (M3) color extraction tool that powers Awe's dynamic wallpaper theme engine.
- **[Quickshell](https://quickshell.outfoxxed.me/)** by [Outfoxxed](https://github.com/outfoxxed) — Powerful, flexible QML-based Wayland desktop shell framework.
- **[Lucide](https://lucide.dev/)** — Clean, modern, consistent vector icons used across the Settings Panel and Widget Pill.
- **[Google Material Design 3](https://m3.material.io/)** — Expressive design guidelines, tonal color system, and typography.
- **Linux Audio & Hardware Telemetry**:
  - [PipeWire / WirePlumber](https://pipewire.org/) (`wpctl`) for audio management.
  - [brightnessctl](https://github.com/Hummer12007/brightnessctl) for monitor backlight control.
  - [playerctl](https://github.com/altdesktop/playerctl) for MPRIS media control.
  - [wl-clipboard](https://github.com/bugaevc/wl-clipboard) for Wayland clipboard history.
  - [lm_sensors](https://github.com/lm-sensors/lm-sensors) for CPU thermals.
  - [awww](https://github.com/AbsolOrg/awww) & [swww](https://github.com/LGFae/swww) for Wayland wallpaper detection.

