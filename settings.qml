import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "."

FloatingWindow {
    id: rootWindow
    title: "Awe Settings"
    implicitWidth: 960
    implicitHeight: 660
    minimumSize: Qt.size(860, 580)
    color: "transparent"

    // ─── Unified Luxury Dark Palette for the Settings Panel (Independent of Awe desktop theme) ───
    readonly property color panelBg: "#090A0F"
    readonly property color panelHeaderBg: "#0D0F16"
    readonly property color panelSidebarBg: "#07080D"
    readonly property color panelCardBg: "#0E111A"
    readonly property color panelCardBorder: "#1C212E"
    readonly property color panelBorder: "#181D28"
    readonly property color panelAccent: "#38BDF8"
    readonly property color panelAccentGreen: "#34D399"
    readonly property color panelAccentWarm: "#FB7185"
    readonly property color panelTextPrimary: "#F8FAFC"
    readonly property color panelTextSecondary: "#94A3B8"
    readonly property color panelPillBg: "#161D2B"
    readonly property color panelHoverBg: "#1E2638"

    // ─── Global State & Config Store ───
    property string activeTab: "themes"
    property var settingsData: ({})
    property var widgetVisibility: ({})
    property bool isShellRunning: false
    property bool isAutostartEnabled: false
    property string searchQuery: ""
    property real globalScaleValue: 0.85

    // Pill notch properties
    property string pillPosition: "top_center"
    property string pillText: "Awe Widgets"
    property bool showPill: true

    // Default widget registry with SVG icon names
    readonly property var allWidgets: [
        { id: "clock",         name: "Clock",               icon: "clock",          cat: "Core",        desc: "Cookie, Nothing OS, Android stacked & digital clock styles" },
        { id: "poster",        name: "Poster / Photo",      icon: "image",          cat: "Media",       desc: "Organic photo frame (Arch, Scallop, Pebble) with GIF support" },
        { id: "calendar",      name: "Calendar",            icon: "calendar",       cat: "Core",        desc: "Interactive monthly calendar with day selector" },
        { id: "media",         name: "Media Player",        icon: "music",          cat: "Media",       desc: "MPRIS controller with fluid seekbar and soundwave bars" },
        { id: "sysinfo",       name: "System Info",         icon: "cpu",            cat: "System",      desc: "CPU load, RAM utilization and disk capacity overview" },
        { id: "battery",       name: "Battery Status",      icon: "battery",        cat: "System",      desc: "Battery percentage, AC adapter status, and power metrics" },
        { id: "weather",       name: "Live Weather",        icon: "cloud",          cat: "Network",     desc: "Current temperature, sky conditions and forecast" },
        { id: "quickcontrols", name: "Volume & Brightness", icon: "volume",         cat: "System",      desc: "PipeWire volume pill and display backlight brightnessctl sliders" },
        { id: "network",       name: "Network Telemetry",   icon: "wifi",           cat: "Network",     desc: "Wi-Fi SSID, bandwidth upload/download sparklines and IP privacy" },
        { id: "notes",         name: "Quick Notes",         icon: "edit",           cat: "Productivity", desc: "Material notepad with instant inline editing and debounced autosave" },
        { id: "todo",          name: "Tasks / Checklist",   icon: "check-square",   cat: "Productivity", desc: "Interactive task list with progress bar and completion tracker" },
        { id: "timer",         name: "Pomodoro Timer",      icon: "timer",          cat: "Productivity", desc: "Focus countdown, break intervals and stopwatch mode" },
        { id: "thermal",       name: "Hardware Thermals",   icon: "thermometer",    cat: "System",      desc: "CPU package & core temperatures via lm_sensors" },
        { id: "quote",         name: "Daily Inspiration",   icon: "quote",          cat: "Media",       desc: "Rotating motivational quotes with author tags and refresh shuffle" },
        { id: "clipboard",     name: "Clipboard History",   icon: "clipboard",      cat: "Productivity", desc: "Real-time clipboard monitor using wl-paste with one-click copy" },
        { id: "crypto",        name: "Crypto Ticker",       icon: "trending",       cat: "Network",     desc: "Live market rates for Bitcoin, Ethereum, Solana with trend pills" },
        { id: "worldclock",    name: "World Clock",         icon: "globe",          cat: "Core",        desc: "Multi-city timezone hub with solar day/night indicators" },
        { id: "git",           name: "Git Dashboard",       icon: "git",            cat: "Productivity", desc: "Repository monitor showing branch, uncommitted diffs and commit message" },
        { id: "resourcewheel", name: "Resource Wheel",      icon: "activity",       cat: "System",      desc: "4 concentric circular progress arcs for CPU, RAM, Disk, Thermals" },
        { id: "visualizer",    name: "Audio Visualizer",    icon: "waveform",       cat: "Media",       desc: "Desktop spectrum equalizer, fluid sine wave, and radial soundwave" },
        { id: "habits",        name: "Habit Tracker",       icon: "calendar-check", cat: "Productivity", desc: "7-day streak tracker with daily interactive check matrix" },
        { id: "ping",          name: "Network Ping",        icon: "activity",       cat: "Network",     desc: "Live latency monitor pinging Cloudflare, Google, GitHub" },
        { id: "storagemap",    name: "Storage Map",         icon: "disc",           cat: "System",      desc: "Segmented disk partition visualizer with Root capacity usage" },
        { id: "calc",          name: "Calculator",          icon: "calculator",     cat: "Core",        desc: "Floating calculator with live expression evaluation" }
    ]

    // ─── Settings Persistence & Shell Process Management ───
    Process {
        id: loadSettingsProc
        command: ["sh", "-c", "cat ~/.config/quickshell/widget_settings.json 2>/dev/null || echo '{}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    rootWindow.settingsData = data
                    if (data.manager) {
                        if (data.manager.visibility !== undefined) {
                            var rawVis = data.manager.visibility
                            if (rawVis.visibility !== undefined) rawVis = rawVis.visibility
                            rootWindow.widgetVisibility = Object.assign({}, rawVis)
                        }
                        if (data.manager.position !== undefined) {
                            rootWindow.pillPosition = data.manager.position
                        }
                        if (data.manager.pillText !== undefined && data.manager.pillText !== "") {
                            rootWindow.pillText = data.manager.pillText
                        }
                        if (data.manager.showPill !== undefined) {
                            rootWindow.showPill = data.manager.showPill
                        }
                    }
                    if (data.clock && data.clock.scale !== undefined) {
                        rootWindow.globalScaleValue = data.clock.scale
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: saveSettingsProc
        running: false
    }

    Process {
        id: checkShellProc
        command: ["sh", "-c", "pgrep -f 'quickshell.*shell\\.qml' >/dev/null && echo 'RUNNING' || echo 'STOPPED'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                rootWindow.isShellRunning = text.indexOf("RUNNING") !== -1
            }
        }
    }

    Process {
        id: checkAutostartProc
        command: ["sh", "-c", "[ -f ~/.config/autostart/awe.desktop ] && echo 'YES' || echo 'NO'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                rootWindow.isAutostartEnabled = text.indexOf("YES") !== -1
            }
        }
    }

    Process {
        id: shellActionProc
        running: false
        onExited: {
            checkShellProc.running = true
        }
    }

    Process {
        id: syncWallpaperProc
        command: ["awe", "wallpaper-sync"]
        running: false
        onExited: {
            loadSettingsProc.running = true
        }
    }

    Timer {
        id: saveDebounceTimer
        interval: 60
        repeat: false
        onTriggered: {
            var visJson = JSON.stringify(rootWindow.widgetVisibility)
            var pyScript = "import json, os; p=os.path.expanduser('~/.config/quickshell/widget_settings.json'); d=json.load(open(p)) if os.path.exists(p) else {}; d.setdefault('manager', {})['visibility']=json.loads(" + JSON.stringify(visJson) + "); open(p,'w').write(json.dumps(d,indent=2))"
            saveSettingsProc.command = ["python3", "-c", pyScript]
            saveSettingsProc.running = true
        }
    }

    Timer {
        id: pollStatusTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!checkShellProc.running) checkShellProc.running = true
            if (!checkAutostartProc.running) checkAutostartProc.running = true
        }
    }

    Component.onCompleted: {
        loadSettingsProc.running = true
        checkShellProc.running = true
        checkAutostartProc.running = true
    }

    function toggleWidget(widgetId) {
        var vis = Object.assign({}, rootWindow.widgetVisibility)
        vis[widgetId] = (vis[widgetId] === false) ? true : false
        rootWindow.widgetVisibility = vis
        saveDebounceTimer.restart()
    }

    function setAllWidgets(enable) {
        var vis = {}
        for (var i = 0; i < allWidgets.length; i++) {
            vis[allWidgets[i].id] = enable
        }
        rootWindow.widgetVisibility = vis
        saveDebounceTimer.restart()
    }

    function setPillPosition(pos) {
        rootWindow.pillPosition = pos
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; d.setdefault(\"manager\", {})[\"position\"]=\"" + pos + "\"; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true
    }

    function setPillText(textVal) {
        rootWindow.pillText = textVal
        var cleanVal = textVal.replace(/"/g, '\\"')
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; d.setdefault(\"manager\", {})[\"pillText\"]=\"" + cleanVal + "\"; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true
    }

    function setPillVisibility(show) {
        rootWindow.showPill = show
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; d.setdefault(\"manager\", {})[\"showPill\"]=" + (show ? "True" : "False") + "; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true
    }

    function setWidgetProp(widgetId, propName, propValue) {
        var valStr = JSON.stringify(propValue).replace(/'/g, "'\\''")
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; d.setdefault(\"" + widgetId + "\", {})[\"" + propName + "\"]=" + valStr + "; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true

        if (!rootWindow.settingsData[widgetId]) rootWindow.settingsData[widgetId] = {}
        rootWindow.settingsData[widgetId][propName] = propValue
    }

    function applyGlobalScale(scaleVal) {
        rootWindow.globalScaleValue = scaleVal
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; widgets=[\"clock\",\"poster\",\"calendar\",\"media\",\"sysinfo\",\"battery\",\"weather\",\"quickcontrols\",\"network\",\"notes\",\"todo\",\"timer\",\"thermal\",\"quote\",\"clipboard\",\"crypto\",\"worldclock\",\"git\",\"resourcewheel\",\"visualizer\",\"habits\",\"ping\",\"storagemap\",\"calc\"]; [d.setdefault(w, {}).update({\"scale\": round(" + scaleVal + ", 2)}) for w in widgets]; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true
    }

    function resetLayoutPositions() {
        var script = "python3 -c 'import json, os; p=os.path.expanduser(\"~/.config/quickshell/widget_settings.json\"); d=json.load(open(p)) if os.path.exists(p) else {}; pos={\"poster\":(30,30),\"calendar\":(30,230),\"visualizer\":(30,460),\"media\":(30,620),\"clipboard\":(30,800),\"sysinfo\":(400,30),\"thermal\":(400,160),\"timer\":(640,160),\"quote\":(400,370),\"todo\":(400,520),\"notes\":(660,520),\"git\":(400,730),\"habits\":(660,730),\"resourcewheel\":(400,890),\"storagemap\":(660,890),\"clock\":(1120,40),\"battery\":(1120,300),\"weather\":(1120,430),\"network\":(1120,580),\"ping\":(1120,730),\"quickcontrols\":(1120,880),\"calc\":(1400,40),\"crypto\":(1400,330),\"worldclock\":(1400,500)}; [d.setdefault(k, {}).update({\"x\": v[0], \"y\": v[1]}) for k, v in pos.items()]; open(p,\"w\").write(json.dumps(d,indent=2))'"
        saveSettingsProc.command = ["sh", "-c", script]
        saveSettingsProc.running = true
        loadSettingsProc.running = true
    }

    function startShell() {
        shellActionProc.command = ["sh", "-c", "awe start"]
        shellActionProc.running = true
    }

    function stopShell() {
        shellActionProc.command = ["sh", "-c", "awe stop"]
        shellActionProc.running = true
    }

    function restartAwe() {
        shellActionProc.command = ["sh", "-c", "awe restart"]
        shellActionProc.running = true
    }

    function toggleAutostart() {
        shellActionProc.command = ["sh", "-c", "awe autostart toggle"]
        shellActionProc.running = true
        checkAutostartProc.running = true
    }

    // ─── Main Outer Container (Razor-Sharp Rich Dark Panel) ───
    Rectangle {
        id: mainPanel
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Qt.quit()
        radius: 8
        color: rootWindow.panelBg
        border.color: rootWindow.panelBorder
        border.width: 1
        antialiasing: true
        clip: true

        // ═══════════════════════════════════════════════════════════════
        // TOP HEADER BAR (Minimal & Balanced)
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: rootWindow.panelHeaderBg
            border.color: rootWindow.panelBorder
            border.width: 1

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    text: "AWE"
                    color: rootWindow.panelAccent
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 2.0
                    font.family: "Google Sans Flex, Google Sans, Inter, monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 1
                    height: 12
                    color: "#25FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CONTROL CENTER"
                    color: rootWindow.panelTextSecondary
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1.0
                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Right Header Controls
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Awe Status Pill
                Rectangle {
                    height: 26
                    width: statusRow.implicitWidth + 16
                    radius: 5
                    color: rootWindow.isShellRunning ? "#1422C55E" : "#14E07A5F"
                    border.color: rootWindow.isShellRunning ? rootWindow.panelAccentGreen : rootWindow.panelAccentWarm
                    border.width: 1

                    Row {
                        id: statusRow
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 6
                            height: 6
                            radius: 3
                            color: rootWindow.isShellRunning ? rootWindow.panelAccentGreen : rootWindow.panelAccentWarm
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: rootWindow.isShellRunning ? "Awe Active" : "Awe Inactive"
                            color: rootWindow.isShellRunning ? rootWindow.panelAccentGreen : rootWindow.panelAccentWarm
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (rootWindow.isShellRunning) rootWindow.stopShell()
                            else rootWindow.startShell()
                        }
                    }
                }

                // Close Button
                Rectangle {
                    id: closeBtn
                    width: 26
                    height: 26
                    radius: 5
                    color: closeHover.hovered ? "#33EF4444" : "#12FFFFFF"
                    border.color: closeHover.hovered ? "#EF4444" : "#1CFFFFFF"
                    border.width: 1

                    AweIcon {
                        anchors.centerIn: parent
                        name: "x"
                        size: 12
                        color: closeHover.hovered ? "#EF4444" : rootWindow.panelTextSecondary
                    }

                    HoverHandler { id: closeHover }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.quit()
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════
        // DUAL-PANE BODY
        // ═══════════════════════════════════════════════════════════════
        Item {
            anchors.top: headerBar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            // ─────────────────────────────────────────────────────────
            // LEFT SIDEBAR
            // ─────────────────────────────────────────────────────────
            Rectangle {
                id: sidebar
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: 190
                color: rootWindow.panelSidebarBg
                border.color: rootWindow.panelBorder
                border.width: 1

                Column {
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    spacing: 3

                    Repeater {
                        model: [
                            { id: "themes",  label: "Themes & Visuals", icon: "palette" },
                            { id: "widgets", label: "Widget Manager",   icon: "widgets" },
                            { id: "pill",    label: "Awe Toggle Pill",  icon: "pin" },
                            { id: "tweaks",  label: "Widget Tweaks",    icon: "sliders" },
                            { id: "layout",  label: "Layout & Scaling", icon: "layout" },
                            { id: "system",  label: "Daemon & Startup", icon: "power" },
                            { id: "about",   label: "CLI & Guide",      icon: "terminal" }
                        ]

                        Rectangle {
                            id: navItem
                            width: sidebar.width - 16
                            height: 36
                            radius: 5
                            color: (rootWindow.activeTab === modelData.id)
                                   ? rootWindow.panelPillBg
                                   : navHover.hovered ? "#0FFFFFFF" : "transparent"
                            border.color: (rootWindow.activeTab === modelData.id) ? rootWindow.panelAccent : "transparent"
                            border.width: (rootWindow.activeTab === modelData.id) ? 1 : 0
                            antialiasing: true

                            HoverHandler { id: navHover }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                AweIcon {
                                    name: modelData.icon
                                    size: 14
                                    color: (rootWindow.activeTab === modelData.id) ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData.label
                                    color: (rootWindow.activeTab === modelData.id) ? rootWindow.panelTextPrimary : rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                    font.bold: (rootWindow.activeTab === modelData.id)
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: rootWindow.activeTab = modelData.id
                            }
                        }
                    }
                }

                // Sidebar Footer: Restart Awe Button
                Column {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    spacing: 6

                    Rectangle {
                        id: restartAweBtn
                        width: parent.width
                        height: 32
                        radius: 5
                        color: restartHover.hovered ? rootWindow.panelPillBg : "#10FFFFFF"
                        border.color: restartHover.hovered ? rootWindow.panelAccent : "#1EFFFFFF"
                        border.width: 1

                        HoverHandler { id: restartHover }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            AweIcon {
                                name: "refresh"
                                size: 12
                                color: rootWindow.panelAccent
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Restart Awe"
                                color: rootWindow.panelTextPrimary
                                font.pixelSize: 11
                                font.bold: true
                                font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: rootWindow.restartAwe()
                        }
                    }
                }
            }

            // ─────────────────────────────────────────────────────────
            // RIGHT CONTENT PANE
            // ─────────────────────────────────────────────────────────
            Item {
                id: contentPane
                anchors.left: sidebar.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 16
                clip: true

                Flickable {
                    id: mainFlickable
                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: currentViewLoader.implicitHeight + 20
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Item {
                        id: currentViewLoader
                        width: mainFlickable.width
                        implicitHeight: {
                            if (rootWindow.activeTab === "themes") return themesView.implicitHeight
                            if (rootWindow.activeTab === "widgets") return widgetsView.implicitHeight
                            if (rootWindow.activeTab === "pill") return pillView.implicitHeight
                            if (rootWindow.activeTab === "tweaks") return tweaksView.implicitHeight
                            if (rootWindow.activeTab === "layout") return layoutView.implicitHeight
                            if (rootWindow.activeTab === "system") return systemView.implicitHeight
                            return aboutView.implicitHeight
                        }

                        // ════════════════════════════════════════════════
                        // TAB 1: THEMES & VISUALS
                        // ════════════════════════════════════════════════
                        Column {
                            id: themesView
                            visible: rootWindow.activeTab === "themes"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Theme Presets"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Select a color theme to apply across your desktop widgets. The Settings panel remains in high-contrast obsidian black."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                            }

                            // ─── Featured: System Dynamic (Wallpaper Palette via Matugen) ───
                            Rectangle {
                                width: parent.width
                                height: 56
                                radius: 6
                                color: (Theme.currentTheme === "system") ? rootWindow.panelPillBg : rootWindow.panelCardBg
                                border.color: (Theme.currentTheme === "system") ? rootWindow.panelAccent : rootWindow.panelCardBorder
                                border.width: 1

                                HoverHandler { id: sysCardHover }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

                                    // Matugen dynamic swatch stack
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 3
                                        Repeater {
                                            model: [
                                                (Theme.systemColors && Theme.systemColors.colBg) ? Theme.systemColors.colBg : "#D9221A14",
                                                (Theme.systemColors && Theme.systemColors.colAccent) ? Theme.systemColors.colAccent : "#FFB77E",
                                                (Theme.systemColors && Theme.systemColors.colAccentGreen) ? Theme.systemColors.colAccentGreen : "#C5CB96",
                                                (Theme.systemColors && Theme.systemColors.colAccentWarm) ? Theme.systemColors.colAccentWarm : "#FFB4AB",
                                                (Theme.systemColors && Theme.systemColors.colAccentWarning) ? Theme.systemColors.colAccentWarning : "#E3C0A6"
                                            ]
                                            Rectangle {
                                                width: 8
                                                height: 26
                                                radius: 2
                                                color: modelData
                                                border.color: "#30FFFFFF"
                                                border.width: 0.5
                                            }
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 210
                                        spacing: 2

                                        Row {
                                            spacing: 6
                                            Text {
                                                text: "System Dynamic"
                                                color: rootWindow.panelTextPrimary
                                                font.pixelSize: 12
                                                font.bold: true
                                                font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                            }
                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                height: 15
                                                radius: 3
                                                width: 58
                                                color: "#1838BDF8"
                                                border.color: "#4038BDF8"
                                                border.width: 1
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "MATUGEN"
                                                    color: rootWindow.panelAccent
                                                    font.pixelSize: 8
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                            }
                                        }

                                        Text {
                                            text: "Dynamic Material 3 palette extracted from desktop wallpaper via Matugen"
                                            color: rootWindow.panelTextSecondary
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            width: parent.width
                                            font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                        }
                                    }

                                    // Action buttons row: Sync & Apply
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6

                                        // Sync Button
                                        Rectangle {
                                            width: 62
                                            height: 24
                                            radius: 4
                                            color: syncHover.hovered ? "#22FFFFFF" : "#14FFFFFF"
                                            border.color: syncHover.hovered ? rootWindow.panelAccent : "#20FFFFFF"
                                            border.width: 1

                                            HoverHandler { id: syncHover }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 4
                                                AweIcon {
                                                    name: "refresh"
                                                    size: 10
                                                    color: rootWindow.panelAccent
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Text {
                                                    text: "SYNC"
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    font.family: "monospace"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: syncWallpaperProc.running = true
                                            }
                                        }

                                        // Apply/Active Button
                                        Rectangle {
                                            width: (Theme.currentTheme === "system") ? 52 : 46
                                            height: 24
                                            radius: 4
                                            color: (Theme.currentTheme === "system")
                                                   ? rootWindow.panelAccent
                                                   : applyHover.hovered ? "#28FFFFFF" : "#18FFFFFF"

                                            HoverHandler { id: applyHover }

                                            Text {
                                                anchors.centerIn: parent
                                                text: (Theme.currentTheme === "system") ? "ACTIVE" : "APPLY"
                                                color: (Theme.currentTheme === "system") ? "#000000" : rootWindow.panelTextSecondary
                                                font.pixelSize: 9
                                                font.bold: true
                                                font.family: "monospace"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: Theme.setTheme("system")
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Theme.setTheme("system")
                                }
                            }

                            Text {
                                text: "Curated Presets"
                                color: rootWindow.panelTextSecondary
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 0.5
                                font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                            }

                            // Clean, flush 2-column grid of 10 Theme Cards with NO awkward whitespace
                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 8

                                Repeater {
                                    model: [
                                        { id: "liquid_glass",   name: "Liquid Glass",   desc: "Translucent frosted glass with specular gloss", swatches: ["#80141B24", "#7DD3FC", "#34D399", "#FB7185"] },
                                        { id: "transparent",    name: "Transparent",    desc: "Minimal see-through floating aesthetic",        swatches: ["#260B0E14", "#38BDF8", "#4ADE80", "#F43F5E"] },
                                        { id: "material",       name: "Material 3",     desc: "Original dark slate with Pixel cyan",            swatches: ["#232D33", "#C2E7FF", "#A2C9C2", "#FFB4AB"] },
                                        { id: "cyberpunk",      name: "Cyberpunk",      desc: "High-contrast neon glow on obsidian",           swatches: ["#0A0B10", "#00FFE0", "#39FF14", "#FF007F"] },
                                        { id: "nordic",         name: "Nordic Frost",   desc: "Arctic cold blue & snow storm palette",         swatches: ["#2E3440", "#88C0D0", "#A3BE8C", "#BF616A"] },
                                        { id: "oled",           name: "OLED Black",     desc: "100% pitch-black with crisp typography",        swatches: ["#000000", "#FFFFFF", "#4ADE80", "#F87171"] },
                                        { id: "warm_latte",     name: "Warm Latte",     desc: "Cozy espresso & caramel with warm amber",       swatches: ["#1E1A16", "#F59E0B", "#84CC16", "#E07A5F"] },
                                        { id: "tokyo_night",    name: "Tokyo Night",    desc: "Midnight indigo-violet with lavender & cyan",    swatches: ["#1A1B26", "#7AA2F7", "#73DACA", "#F7768E"] },
                                        { id: "evergreen_moss", name: "Evergreen",      desc: "Forest green with phosphor telemetry",          swatches: ["#8A0C1A12", "#22C55E", "#86EFAC", "#FB923C"] },
                                        { id: "aurora_prism",   name: "Aurora Prism",   desc: "Crystal glass with iridescent reflections",     swatches: ["#78161826", "#E879F9", "#34D399", "#FB7185"] }
                                    ]

                                    Rectangle {
                                        width: (themesView.width - 8) / 2
                                        height: 52
                                        radius: 6
                                        color: (Theme.currentTheme === modelData.id) ? rootWindow.panelPillBg : rootWindow.panelCardBg
                                        border.color: (Theme.currentTheme === modelData.id) ? rootWindow.panelAccent : rootWindow.panelCardBorder
                                        border.width: 1

                                        HoverHandler { id: cardHover }

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            // Swatch stack
                                            Row {
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 3
                                                Repeater {
                                                    model: modelData.swatches
                                                    Rectangle {
                                                        width: 8
                                                        height: 24
                                                        radius: 2
                                                        color: modelData
                                                        border.color: "#30FFFFFF"
                                                        border.width: 0.5
                                                    }
                                                }
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 110
                                                spacing: 2

                                                Text {
                                                    text: modelData.name
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                                }

                                                Text {
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                    width: parent.width
                                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                                }
                                            }

                                            // Status Badge
                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: (Theme.currentTheme === modelData.id) ? 50 : 44
                                                height: 20
                                                radius: 4
                                                color: (Theme.currentTheme === modelData.id)
                                                       ? rootWindow.panelAccent
                                                       : cardHover.hovered ? "#20FFFFFF" : "#12FFFFFF"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (Theme.currentTheme === modelData.id) ? "ACTIVE" : "APPLY"
                                                    color: (Theme.currentTheme === modelData.id) ? "#000000" : rootWindow.panelTextSecondary
                                                    font.pixelSize: 9
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Theme.setTheme(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 2: WIDGET MANAGER
                        // ════════════════════════════════════════════════
                        Column {
                            id: widgetsView
                            visible: rootWindow.activeTab === "widgets"
                            width: parent.width
                            spacing: 12

                            Column {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: "Widget Suite Manager"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    // Search Bar
                                    Rectangle {
                                        width: parent.width - 200
                                        height: 32
                                        radius: 5
                                        color: rootWindow.panelCardBg
                                        border.color: rootWindow.panelCardBorder
                                        border.width: 1

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            AweIcon {
                                                name: "search"
                                                size: 13
                                                color: rootWindow.panelTextSecondary
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            TextInput {
                                                id: searchInput
                                                width: parent.width - 30
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: rootWindow.panelTextPrimary
                                                font.pixelSize: 11
                                                font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                                onTextChanged: rootWindow.searchQuery = text.toLowerCase().trim()
                                                clip: true
                                                Text {
                                                    visible: !searchInput.text
                                                    text: "Filter widgets (clock, media, timer)..."
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 11
                                                }
                                            }
                                        }
                                    }

                                    // Enable All
                                    Rectangle {
                                        width: 95
                                        height: 32
                                        radius: 5
                                        color: enHover.hovered ? rootWindow.panelPillBg : "#10FFFFFF"
                                        border.color: rootWindow.panelAccentGreen
                                        border.width: 1

                                        HoverHandler { id: enHover }
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Enable All"
                                            color: rootWindow.panelAccentGreen
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: rootWindow.setAllWidgets(true)
                                        }
                                    }

                                    // Disable All
                                    Rectangle {
                                        width: 95
                                        height: 32
                                        radius: 5
                                        color: disHover.hovered ? "#22EF4444" : "#10FFFFFF"
                                        border.color: "#28FFFFFF"
                                        border.width: 1

                                        HoverHandler { id: disHover }
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Disable All"
                                            color: rootWindow.panelTextSecondary
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: rootWindow.setAllWidgets(false)
                                        }
                                    }
                                }
                            }

                            // 2-Column Grid of 24 Widgets
                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 8

                                Repeater {
                                    model: {
                                        if (!rootWindow.searchQuery) return rootWindow.allWidgets
                                        return rootWindow.allWidgets.filter(function(w) {
                                            return w.name.toLowerCase().indexOf(rootWindow.searchQuery) !== -1 ||
                                                   w.id.toLowerCase().indexOf(rootWindow.searchQuery) !== -1 ||
                                                   w.cat.toLowerCase().indexOf(rootWindow.searchQuery) !== -1
                                        })
                                    }

                                    Rectangle {
                                        width: (widgetsView.width - 8) / 2
                                        height: 52
                                        radius: 6
                                        color: (rootWindow.widgetVisibility[modelData.id] !== false) ? rootWindow.panelCardBg : "#080A0F"
                                        border.color: (rootWindow.widgetVisibility[modelData.id] !== false) ? rootWindow.panelCardBorder : "#14FFFFFF"
                                        border.width: 1

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            AweIcon {
                                                name: modelData.icon
                                                size: 16
                                                color: (rootWindow.widgetVisibility[modelData.id] !== false) ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 66
                                                spacing: 2

                                                Row {
                                                    spacing: 6
                                                    Text {
                                                        text: modelData.name
                                                        color: (rootWindow.widgetVisibility[modelData.id] !== false) ? rootWindow.panelTextPrimary : rootWindow.panelTextSecondary
                                                        font.pixelSize: 12
                                                        font.bold: true
                                                    }
                                                    Rectangle {
                                                        width: 36
                                                        height: 14
                                                        radius: 3
                                                        color: "#12FFFFFF"
                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: modelData.cat
                                                            color: rootWindow.panelAccent
                                                            font.pixelSize: 8
                                                            font.bold: true
                                                        }
                                                    }
                                                }

                                                Text {
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                    width: parent.width
                                                }
                                            }

                                            // Minimalist Switch
                                            Rectangle {
                                                width: 34
                                                height: 18
                                                radius: 9
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: (rootWindow.widgetVisibility[modelData.id] !== false) ? rootWindow.panelAccent : "#242A36"

                                                Rectangle {
                                                    width: 12
                                                    height: 12
                                                    radius: 6
                                                    y: 3
                                                    x: (rootWindow.widgetVisibility[modelData.id] !== false) ? 19 : 3
                                                    color: (rootWindow.widgetVisibility[modelData.id] !== false) ? "#000000" : "#7E8795"
                                                    Behavior on x { NumberAnimation { duration: 120 } }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.toggleWidget(modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 3: AWE TOGGLE PILL & NOTCH SETTINGS
                        // ════════════════════════════════════════════════
                        Column {
                            id: pillView
                            visible: rootWindow.activeTab === "pill"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Desktop Pill & Toggle Notch"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Reposition the floating notch on your desktop, customize its title text, or hide it completely."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                            }

                            // Visibility Toggle Card
                            Rectangle {
                                width: parent.width
                                height: 56
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    AweIcon {
                                        name: rootWindow.showPill ? "eye" : "eye-off"
                                        size: 18
                                        color: rootWindow.showPill ? rootWindow.panelAccentGreen : rootWindow.panelTextSecondary
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 80
                                        spacing: 2

                                        Text {
                                            text: "Show Desktop Toggle Pill"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Text {
                                            text: rootWindow.showPill ? "Pill notch is active on desktop" : "Pill notch is hidden (control widgets via 'awe' in terminal)"
                                            color: rootWindow.panelTextSecondary
                                            font.pixelSize: 10
                                        }
                                    }

                                    Rectangle {
                                        width: 34
                                        height: 18
                                        radius: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: rootWindow.showPill ? rootWindow.panelAccentGreen : "#262C38"

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            y: 3
                                            x: rootWindow.showPill ? 19 : 3
                                            color: rootWindow.showPill ? "#000000" : "#808A98"
                                            Behavior on x { NumberAnimation { duration: 120 } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: rootWindow.setPillVisibility(!rootWindow.showPill)
                                        }
                                    }
                                }
                            }

                            // Screen Edge Position Selector
                            Rectangle {
                                width: parent.width
                                height: 120
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        AweIcon { name: "pin"; size: 14; color: rootWindow.panelAccent }
                                        Text {
                                            text: "Screen Placement"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Grid {
                                        columns: 3
                                        spacing: 8
                                        width: parent.width

                                        Repeater {
                                            model: [
                                                { id: "top_left",      label: "Top Left" },
                                                { id: "top_center",    label: "Top Center (Default)" },
                                                { id: "top_right",     label: "Top Right" },
                                                { id: "bottom_left",   label: "Bottom Left" },
                                                { id: "bottom_center", label: "Bottom Center" },
                                                { id: "bottom_right",  label: "Bottom Right" }
                                            ]

                                            Rectangle {
                                                width: (pillView.width - 40) / 3
                                                height: 32
                                                radius: 5
                                                property bool isCur: rootWindow.pillPosition === modelData.id
                                                color: isCur ? rootWindow.panelPillBg : "#10FFFFFF"
                                                border.color: isCur ? rootWindow.panelAccent : "#1EFFFFFF"
                                                border.width: isCur ? 1.5 : 1

                                                Row {
                                                    anchors.centerIn: parent
                                                    spacing: 6
                                                    AweIcon {
                                                        name: "pin"
                                                        size: 11
                                                        color: parent.parent.isCur ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                    }
                                                    Text {
                                                        text: modelData.label
                                                        color: parent.parent.isCur ? rootWindow.panelAccent : rootWindow.panelTextPrimary
                                                        font.pixelSize: 11
                                                        font.bold: parent.parent.isCur
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.setPillPosition(modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Custom Text Label Card
                            Rectangle {
                                width: parent.width
                                height: 85
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        AweIcon { name: "edit"; size: 14; color: rootWindow.panelAccent }
                                        Text {
                                            text: "Custom Pill Label Text"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Rectangle {
                                            width: parent.width - 96
                                            height: 32
                                            radius: 5
                                            color: "#121622"
                                            border.color: "#22FFFFFF"
                                            border.width: 1

                                            TextInput {
                                                id: pillTextInput
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                color: rootWindow.panelTextPrimary
                                                font.pixelSize: 11
                                                text: rootWindow.pillText
                                                onAccepted: rootWindow.setPillText(text.trim())
                                            }
                                        }

                                        Rectangle {
                                            width: 88
                                            height: 32
                                            radius: 5
                                            color: rootWindow.panelPillBg
                                            border.color: rootWindow.panelAccent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Save Text"
                                                color: rootWindow.panelAccent
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: rootWindow.setPillText(pillTextInput.text.trim())
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 4: WIDGET TWEAKS
                        // ════════════════════════════════════════════════
                        Column {
                            id: tweaksView
                            visible: rootWindow.activeTab === "tweaks"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Per-Widget Customization"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Fine-tune individual widget parameters, clock styles, and poster frame shapes."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                }
                            }

                            // 1. Clock Style
                            Rectangle {
                                width: parent.width
                                height: 75
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        AweIcon { name: "clock"; size: 14; color: rootWindow.panelAccent }
                                        Text {
                                            text: "Clock Widget Style"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        spacing: 8
                                        Repeater {
                                            model: [
                                                { id: "cookie", label: "Cookie Style" },
                                                { id: "nothing", label: "Nothing OS" },
                                                { id: "androidStacked", label: "Android Stacked" },
                                                { id: "digital", label: "Digital Typo" }
                                            ]

                                            Rectangle {
                                                width: (tweaksView.width - 44) / 4
                                                height: 30
                                                radius: 5
                                                property bool isSelected: (rootWindow.settingsData.clock && rootWindow.settingsData.clock.style === modelData.id) || (modelData.id === "cookie" && (!rootWindow.settingsData.clock || !rootWindow.settingsData.clock.style))
                                                color: isSelected ? rootWindow.panelPillBg : "#10FFFFFF"
                                                border.color: isSelected ? rootWindow.panelAccent : "#1EFFFFFF"
                                                border.width: isSelected ? 1.5 : 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    color: parent.isSelected ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                    font.pixelSize: 11
                                                    font.bold: parent.isSelected
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.setWidgetProp("clock", "style", modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 2. Poster Shape
                            Rectangle {
                                width: parent.width
                                height: 75
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        AweIcon { name: "image"; size: 14; color: rootWindow.panelAccent }
                                        Text {
                                            text: "Poster Frame Shape"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        spacing: 6
                                        Repeater {
                                            model: [
                                                { idx: 0, label: "Arch" },
                                                { idx: 1, label: "Scallop" },
                                                { idx: 2, label: "Squircle" },
                                                { idx: 3, label: "Pebble" },
                                                { idx: 4, label: "Heart" },
                                                { idx: 5, label: "Flower" },
                                                { idx: 6, label: "Stadium" }
                                            ]

                                            Rectangle {
                                                width: (tweaksView.width - 56) / 7
                                                height: 30
                                                radius: 5
                                                property bool isSelected: (rootWindow.settingsData.poster && rootWindow.settingsData.poster.shapeIndex === modelData.idx) || (modelData.idx === 1 && (!rootWindow.settingsData.poster || rootWindow.settingsData.poster.shapeIndex === undefined))
                                                color: isSelected ? rootWindow.panelPillBg : "#10FFFFFF"
                                                border.color: isSelected ? rootWindow.panelAccent : "#1EFFFFFF"
                                                border.width: isSelected ? 1.5 : 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    color: parent.isSelected ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    font.bold: parent.isSelected
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.setWidgetProp("poster", "shapeIndex", modelData.idx)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 3. Visualizer Modes
                            Rectangle {
                                width: parent.width
                                height: 75
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    Row {
                                        spacing: 6
                                        AweIcon { name: "waveform"; size: 14; color: rootWindow.panelAccent }
                                        Text {
                                            text: "Audio Visualizer Mode"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        spacing: 8
                                        Repeater {
                                            model: [
                                                { id: "bars", label: "16-Bar Spectrum" },
                                                { id: "wave", label: "Fluid Sine Wave" },
                                                { id: "radial", label: "Radial Soundwave" }
                                            ]

                                            Rectangle {
                                                width: (tweaksView.width - 36) / 3
                                                height: 30
                                                radius: 5
                                                property bool isSelected: (rootWindow.settingsData.visualizer && rootWindow.settingsData.visualizer.mode === modelData.id) || (modelData.id === "bars" && (!rootWindow.settingsData.visualizer || !rootWindow.settingsData.visualizer.mode))
                                                color: isSelected ? rootWindow.panelPillBg : "#10FFFFFF"
                                                border.color: isSelected ? rootWindow.panelAccent : "#1EFFFFFF"
                                                border.width: isSelected ? 1.5 : 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    color: parent.isSelected ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                    font.pixelSize: 11
                                                    font.bold: parent.isSelected
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.setWidgetProp("visualizer", "mode", modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 5: LAYOUT & SCALING
                        // ════════════════════════════════════════════════
                        Column {
                            id: layoutView
                            visible: rootWindow.activeTab === "layout"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Layout & Master Scaling"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Adjust scale factor across all widgets or restore default coordinates."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                }
                            }

                            // Scale Presets
                            Rectangle {
                                width: parent.width
                                height: 85
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Row {
                                        width: parent.width
                                        Text {
                                            text: "Master Widget Scale Factor"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Item { Layout.fillWidth: true; width: 100 }
                                        Text {
                                            text: rootWindow.globalScaleValue.toFixed(2) + "x"
                                            color: rootWindow.panelAccent
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        spacing: 8
                                        Repeater {
                                            model: [
                                                { label: "0.75x Compact", val: 0.75 },
                                                { label: "0.85x Standard", val: 0.85 },
                                                { label: "1.00x Native",   val: 1.00 },
                                                { label: "1.15x Large",    val: 1.15 }
                                            ]

                                            Rectangle {
                                                width: (layoutView.width - 48) / 4
                                                height: 30
                                                radius: 5
                                                property bool isCur: Math.abs(rootWindow.globalScaleValue - modelData.val) < 0.04
                                                color: isCur ? rootWindow.panelPillBg : "#10FFFFFF"
                                                border.color: isCur ? rootWindow.panelAccent : "#1EFFFFFF"
                                                border.width: 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.label
                                                    color: parent.isCur ? rootWindow.panelAccent : rootWindow.panelTextSecondary
                                                    font.pixelSize: 11
                                                    font.bold: parent.isCur
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: rootWindow.applyGlobalScale(modelData.val)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Reset Grid Card
                            Rectangle {
                                width: parent.width
                                height: 56
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Column {
                                        width: parent.width - 160
                                        spacing: 2
                                        Text {
                                            text: "Reset Desktop Grid Coordinates"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Text {
                                            text: "Restores standard clean multi-column desktop layout."
                                            color: rootWindow.panelTextSecondary
                                            font.pixelSize: 10
                                        }
                                    }

                                    Rectangle {
                                        width: 140
                                        height: 32
                                        radius: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: "#12FFFFFF"
                                        border.color: "#28FFFFFF"
                                        border.width: 1

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            AweIcon { name: "refresh"; size: 12; color: rootWindow.panelTextPrimary }
                                            Text {
                                                text: "Reset Positions"
                                                color: rootWindow.panelTextPrimary
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: rootWindow.resetLayoutPositions()
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 6: DAEMON & STARTUP
                        // ════════════════════════════════════════════════
                        Column {
                            id: systemView
                            visible: rootWindow.activeTab === "system"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Daemon & Desktop Startup"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Control background quickshell processes and desktop login autostart."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                }
                            }

                            // Process Controls
                            Rectangle {
                                width: parent.width
                                height: 85
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Row {
                                        width: parent.width
                                        Text {
                                            text: "Awe Desktop Widgets Daemon"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Item { Layout.fillWidth: true; width: 100 }
                                        Text {
                                            text: rootWindow.isShellRunning ? "ACTIVE" : "STOPPED"
                                            color: rootWindow.isShellRunning ? rootWindow.panelAccentGreen : rootWindow.panelAccentWarm
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    Row {
                                        spacing: 8

                                        Rectangle {
                                            width: (systemView.width - 40) / 3
                                            height: 30
                                            radius: 5
                                            color: rootWindow.isShellRunning ? "#0EFFFFFF" : "#1A22C55E"
                                            border.color: rootWindow.isShellRunning ? "#20FFFFFF" : rootWindow.panelAccentGreen
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Start Awe"
                                                color: rootWindow.isShellRunning ? rootWindow.panelTextSecondary : rootWindow.panelAccentGreen
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: rootWindow.startShell()
                                            }
                                        }

                                        Rectangle {
                                            width: (systemView.width - 40) / 3
                                            height: 30
                                            radius: 5
                                            color: rootWindow.panelPillBg
                                            border.color: rootWindow.panelAccent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Restart Awe"
                                                color: rootWindow.panelAccent
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: rootWindow.restartAwe()
                                            }
                                        }

                                        Rectangle {
                                            width: (systemView.width - 40) / 3
                                            height: 30
                                            radius: 5
                                            color: "#10FFFFFF"
                                            border.color: "#25FFFFFF"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Stop Awe"
                                                color: rootWindow.panelTextSecondary
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: rootWindow.stopShell()
                                            }
                                        }
                                    }
                                }
                            }

                            // Autostart Card
                            Rectangle {
                                width: parent.width
                                height: 56
                                radius: 6
                                color: rootWindow.panelCardBg
                                border.color: rootWindow.panelCardBorder
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Column {
                                        width: parent.width - 80
                                        spacing: 2
                                        Text {
                                            text: "Autostart on Desktop Login"
                                            color: rootWindow.panelTextPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Text {
                                            text: "Automatically launches Awe in background on user login."
                                            color: rootWindow.panelTextSecondary
                                            font.pixelSize: 10
                                        }
                                    }

                                    Rectangle {
                                        width: 34
                                        height: 18
                                        radius: 9
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: rootWindow.isAutostartEnabled ? rootWindow.panelAccentGreen : "#262C38"

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            y: 3
                                            x: rootWindow.isAutostartEnabled ? 19 : 3
                                            color: rootWindow.isAutostartEnabled ? "#000000" : "#808A98"
                                            Behavior on x { NumberAnimation { duration: 120 } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: rootWindow.toggleAutostart()
                                        }
                                    }
                                }
                            }
                        }

                        // ════════════════════════════════════════════════
                        // TAB 7: CLI & TERMINAL CHEATSHEET (Luxury Redesign)
                        // ════════════════════════════════════════════════
                        Column {
                            id: aboutView
                            visible: rootWindow.activeTab === "about"
                            width: parent.width
                            spacing: 12

                            Column {
                                spacing: 2
                                Text {
                                    text: "Command Line Cheatsheet"
                                    color: rootWindow.panelTextPrimary
                                    font.pixelSize: 15
                                    font.bold: true
                                    font.family: "Google Sans Flex, Google Sans, Inter, sans-serif"
                                }
                                Text {
                                    text: "Every widget, theme, and desktop state can be queried and toggled directly via 'awe'."
                                    color: rootWindow.panelTextSecondary
                                    font.pixelSize: 11
                                }
                            }

                            // Quick Terminal Banner
                            Rectangle {
                                width: parent.width
                                height: 42
                                radius: 5
                                color: "#06080E"
                                border.color: rootWindow.panelAccent
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        text: "$ awe --help"
                                        color: rootWindow.panelAccent
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.family: "monospace"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle { width: 1; height: 12; color: "#25FFFFFF"; anchors.verticalCenter: parent.verticalCenter }

                                    Text {
                                        text: "Comprehensive CLI companion installed to ~/.local/bin/awe"
                                        color: rootWindow.panelTextSecondary
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Categorized Cheatsheet Cards (Aligned & Clean)
                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 8

                                // Card 1: Core & Daemon
                                Rectangle {
                                    width: (aboutView.width - 8) / 2
                                    height: 145
                                    radius: 6
                                    color: rootWindow.panelCardBg
                                    border.color: rootWindow.panelCardBorder
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 6

                                        Text {
                                            text: "CORE & DAEMON ACTIONS"
                                            color: rootWindow.panelAccent
                                            font.pixelSize: 9
                                            font.bold: true
                                            font.letterSpacing: 1.0
                                            font.family: "monospace"
                                        }

                                        Repeater {
                                            model: [
                                                { cmd: "awe",         desc: "Launch rich settings GUI" },
                                                { cmd: "awe start",   desc: "Start desktop widgets in background" },
                                                { cmd: "awe stop",    desc: "Stop running widgets" },
                                                { cmd: "awe restart", desc: "Restart Awe desktop widgets" },
                                                { cmd: "awe status",  desc: "Print terminal status report" }
                                            ]

                                            Row {
                                                width: parent.width
                                                spacing: 8
                                                Text {
                                                    width: 80
                                                    text: modelData.cmd
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                                Text {
                                                    width: parent.width - 88
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }
                                }

                                // Card 2: Appearance & Themes
                                Rectangle {
                                    width: (aboutView.width - 8) / 2
                                    height: 145
                                    radius: 6
                                    color: rootWindow.panelCardBg
                                    border.color: rootWindow.panelCardBorder
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 6

                                        Text {
                                            text: "THEMES & PALETTES"
                                            color: rootWindow.panelAccent
                                            font.pixelSize: 9
                                            font.bold: true
                                            font.letterSpacing: 1.0
                                            font.family: "monospace"
                                        }

                                        Repeater {
                                            model: [
                                                { cmd: "awe theme",           desc: "List all 10 available themes" },
                                                { cmd: "awe theme oled",      desc: "Switch to 100% pitch-black" },
                                                { cmd: "awe theme cyberpunk", desc: "Switch to neon cyberpunk glow" },
                                                { cmd: "awe theme nordic",    desc: "Switch to arctic cold blue" },
                                                { cmd: "awe theme glass",     desc: "Switch to translucent glass" }
                                            ]

                                            Row {
                                                width: parent.width
                                                spacing: 8
                                                Text {
                                                    width: 120
                                                    text: modelData.cmd
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                                Text {
                                                    width: parent.width - 128
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }
                                }

                                // Card 3: Desktop Pill & Notch
                                Rectangle {
                                    width: (aboutView.width - 8) / 2
                                    height: 145
                                    radius: 6
                                    color: rootWindow.panelCardBg
                                    border.color: rootWindow.panelCardBorder
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 6

                                        Text {
                                            text: "DESKTOP PILL NOTCH"
                                            color: rootWindow.panelAccent
                                            font.pixelSize: 9
                                            font.bold: true
                                            font.letterSpacing: 1.0
                                            font.family: "monospace"
                                        }

                                        Repeater {
                                            model: [
                                                { cmd: "awe pill",               desc: "Show current pill position" },
                                                { cmd: "awe pill bottom_center", desc: "Move pill to screen bottom" },
                                                { cmd: "awe pill top_left",      desc: "Pin pill to top-left edge" },
                                                { cmd: "awe pill-text <text>",   desc: "Set custom label on pill" },
                                                { cmd: "awe pill-toggle",        desc: "Show or hide pill completely" }
                                            ]

                                            Row {
                                                width: parent.width
                                                spacing: 8
                                                Text {
                                                    width: 135
                                                    text: modelData.cmd
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                                Text {
                                                    width: parent.width - 143
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }
                                }

                                // Card 4: Widgets & System
                                Rectangle {
                                    width: (aboutView.width - 8) / 2
                                    height: 145
                                    radius: 6
                                    color: rootWindow.panelCardBg
                                    border.color: rootWindow.panelCardBorder
                                    border.width: 1

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 6

                                        Text {
                                            text: "WIDGETS & SYSTEM"
                                            color: rootWindow.panelAccent
                                            font.pixelSize: 9
                                            font.bold: true
                                            font.letterSpacing: 1.0
                                            font.family: "monospace"
                                        }

                                        Repeater {
                                            model: [
                                                { cmd: "awe list",             desc: "List all 24 widgets and states" },
                                                { cmd: "awe toggle <widget>",  desc: "Toggle widget visibility" },
                                                { cmd: "awe scale <0.5-1.5>",  desc: "Set master scale factor" },
                                                { cmd: "awe autostart [on|off]", desc: "Toggle launch on login" },
                                                { cmd: "awe install",          desc: "Relink ~/.local/bin/awe binary" }
                                            ]

                                            Row {
                                                width: parent.width
                                                spacing: 8
                                                Text {
                                                    width: 135
                                                    text: modelData.cmd
                                                    color: rootWindow.panelTextPrimary
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    font.family: "monospace"
                                                }
                                                Text {
                                                    width: parent.width - 143
                                                    text: modelData.desc
                                                    color: rootWindow.panelTextSecondary
                                                    font.pixelSize: 10
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Minimalist Scrollbar
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 1
                    width: 2
                    radius: 1
                    color: "#12FFFFFF"
                    visible: mainFlickable.contentHeight > mainFlickable.height

                    Rectangle {
                        width: parent.width
                        height: Math.max(20, (mainFlickable.height / mainFlickable.contentHeight) * mainFlickable.height)
                        y: (mainFlickable.contentY / (mainFlickable.contentHeight - mainFlickable.height)) * (mainFlickable.height - height)
                        radius: 1
                        color: rootWindow.panelAccent
                        antialiasing: true
                    }
                }
            }
        }
    }
}
