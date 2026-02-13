import Cocoa

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var timer: Timer?

    // Stopwatch state
    private var isRunning = false
    private var accumulatedSeconds: TimeInterval = 0
    private var startedAt: Date?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = formatTime(0)

        // Menu
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Start / Stop", action: #selector(toggleStartStop), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Reset", action: #selector(reset), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set Start Time…", action: #selector(setStartTime), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items { item.target = self }
        statusItem.menu = menu

        // Update every second
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    // MARK: - Actions

    @objc private func toggleStartStop() {
        if isRunning {
            // Stop: fold running time into accumulated
            accumulatedSeconds = currentElapsedSeconds()
            startedAt = nil
            isRunning = false
        } else {
            // Start: set reference point so elapsed = accumulated + (now - startedAt)
            startedAt = Date()
            isRunning = true
        }
        updateMenuBarTitle()
    }

    @objc private func reset() {
        accumulatedSeconds = 0
        if isRunning {
            startedAt = Date()
        }
        updateMenuBarTitle()
    }

    @objc private func setStartTime() {
        let alert = NSAlert()
        alert.messageText = "Set start time"
        alert.informativeText = "Enter a time in HH:MM:SS (e.g. 00:45:00)."
        alert.alertStyle = .informational

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 220, height: 24))
        input.placeholderString = "HH:MM:SS"
        input.stringValue = formatTime(Int(currentElapsedSeconds()))
        alert.accessoryView = input

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let text = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let seconds = parseHHMMSS(text) else {
            showError("Invalid time. Please use HH:MM:SS (e.g. 01:02:03).")
            return
        }

        accumulatedSeconds = TimeInterval(seconds)
        if isRunning {
            // Keep running from the new starting elapsed value
            startedAt = Date()
        }
        updateMenuBarTitle()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Timer tick

    @objc private func tick() {
        updateMenuBarTitle()
    }

    // MARK: - Helpers

    private func currentElapsedSeconds() -> TimeInterval {
        if isRunning, let startedAt {
            return accumulatedSeconds + Date().timeIntervalSince(startedAt)
        } else {
            return accumulatedSeconds
        }
    }

    private func updateMenuBarTitle() {
        let elapsed = Int(currentElapsedSeconds())
        statusItem.button?.title = formatTime(elapsed)
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let s = max(0, totalSeconds)
        let hours = s / 3600
        let minutes = (s % 3600) / 60
        let seconds = s % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func parseHHMMSS(_ text: String) -> Int? {
        // Accept exactly 3 components separated by ":"
        let parts = text.split(separator: ":").map(String.init)
        guard parts.count == 3 else { return nil }
        guard let h = Int(parts[0]), let m = Int(parts[1]), let s = Int(parts[2]) else { return nil }
        guard h >= 0, (0...59).contains(m), (0...59).contains(s) else { return nil }
        return h * 3600 + m * 60 + s
    }

    private func showError(_ message: String) {
        let a = NSAlert()
        a.messageText = "Error"
        a.informativeText = message
        a.alertStyle = .warning
        a.addButton(withTitle: "OK")
        a.runModal()
    }
}
