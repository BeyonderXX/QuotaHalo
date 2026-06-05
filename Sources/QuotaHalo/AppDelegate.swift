import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let store = QuotaStore()
    private let settings = SettingsStore()
    private let provider = QuotaProvider()
    private var panel: WidgetPanel?
    private var setupWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var keepAboveApps = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        provider.prepareSupportFiles()
        makePanel()
        makeStatusItem()
        store.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.stop()
        savePanelFrame()
    }

    private func makePanel() {
        let frame = restoredFrame()
        let panel = WidgetPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.delegate = self
        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        panel.level = desktopWidgetLevel()
        panel.contentView = NSHostingView(rootView: QuotaWidgetView(store: store, settings: settings))
        panel.orderFrontRegardless()

        self.panel = panel
    }

    private func makeStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "gauge.medium", accessibilityDescription: "Codex quota")
            button.image?.isTemplate = true
            if button.image == nil {
                button.title = "CX"
            }
        }

        item.menu = makeMenu()
        self.statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: settings.text(.refreshNow), action: #selector(refreshNow), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: settings.text(.showHide), action: #selector(togglePanel), keyEquivalent: "h"))

        let keepOnTopItem = NSMenuItem(title: settings.text(.keepOnTop), action: #selector(toggleKeepAboveApps), keyEquivalent: "t")
        keepOnTopItem.state = keepAboveApps ? .on : .off
        menu.addItem(keepOnTopItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: settings.text(.openUsagePage), action: #selector(openCodexUsagePage), keyEquivalent: "u"))
        menu.addItem(NSMenuItem(title: settings.text(.openManualJSON), action: #selector(openManualUsageFile), keyEquivalent: "j"))
        menu.addItem(NSMenuItem(title: settings.text(.setup), action: #selector(showSetupWindow), keyEquivalent: ","))

        let languageMenu = NSMenu()
        for language in AppLanguage.allCases {
            let item = NSMenuItem(title: language.displayName, action: #selector(setLanguage(_:)), keyEquivalent: "")
            item.representedObject = language.rawValue
            item.state = settings.language == language ? .on : .off
            languageMenu.addItem(item)
        }
        let languageItem = NSMenuItem(title: settings.text(.language), action: nil, keyEquivalent: "")
        languageItem.submenu = languageMenu
        menu.addItem(languageItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: settings.text(.quit), action: #selector(quit), keyEquivalent: "q"))
        return menu
    }

    @objc private func refreshNow() {
        store.refresh()
    }

    @objc private func togglePanel() {
        guard let panel else { return }
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFrontRegardless()
        }
    }

    @objc private func toggleKeepAboveApps(_ sender: NSMenuItem) {
        keepAboveApps.toggle()
        sender.state = keepAboveApps ? .on : .off
        panel?.level = keepAboveApps ? .floating : desktopWidgetLevel()
        panel?.orderFrontRegardless()
    }

    @objc private func setLanguage(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let language = AppLanguage(rawValue: raw) else {
            return
        }
        settings.language = language
        statusItem?.menu = makeMenu()
        if setupWindow?.isVisible == true {
            showSetupWindow()
        }
    }

    @objc private func openCodexUsagePage() {
        guard let url = URL(string: "https://chatgpt.com/codex/settings/usage") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func openManualUsageFile() {
        let url = provider.ensureManualUsageFile()
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    @objc private func showSetupWindow() {
        if let setupWindow, setupWindow.isVisible {
            setupWindow.close()
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 310),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = settings.text(.setupTitle)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SetupWindowView(
            settings: settings,
            onOpenCodexApp: { [weak self] in self?.openCodexApp() },
            onStartLogin: { [weak self] in self?.startCodexLogin() },
            onRefresh: { [weak self] in self?.store.refresh() },
            onClose: { [weak window] in window?.close() }
        ))
        window.center()
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        setupWindow = window
    }

    private func openCodexApp() {
        let codexApp = URL(fileURLWithPath: "/Applications/Codex.app")
        if FileManager.default.fileExists(atPath: codexApp.path) {
            NSWorkspace.shared.open(codexApp)
            return
        }

        if let url = URL(string: "https://github.com/openai/codex") {
            NSWorkspace.shared.open(url)
        }
    }

    private func startCodexLogin() {
        let commandURL = provider.supportDirectory.appendingPathComponent("codex-login.command")
        provider.prepareSupportFiles()

        let script = """
        #!/bin/zsh
        clear
        echo "QuotaHalo"
        echo "Starting the official Codex login flow..."
        echo ""
        if command -v codex >/dev/null 2>&1; then
          codex login
        elif [ -x "/Applications/Codex.app/Contents/Resources/codex" ]; then
          "/Applications/Codex.app/Contents/Resources/codex" login
        else
          echo "Codex was not found."
          echo "Install Codex first, then run this setup again."
          echo "https://github.com/openai/codex"
        fi
        echo ""
        echo "When login is complete, return to QuotaHalo and click Refresh."
        echo "You can close this window."
        read -k 1 "?Press any key to close..."
        """

        do {
            try script.write(to: commandURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: commandURL.path)
            NSWorkspace.shared.open(commandURL)
        } catch {
            openCodexApp()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    func windowDidMove(_ notification: Notification) {
        savePanelFrame()
    }

    private func desktopWidgetLevel() -> NSWindow.Level {
        NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)
    }

    private func restoredFrame() -> NSRect {
        let side: CGFloat = 204
        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)

        if let rawFrame = UserDefaults.standard.string(forKey: "WidgetFrame") {
            var frame = NSRectFromString(rawFrame)
            if visibleFrame.intersects(frame), frame.width > 80, frame.height > 80 {
                frame.size = NSSize(width: side, height: side)
                return frame
            }
        }

        return NSRect(
            x: visibleFrame.maxX - side - 32,
            y: visibleFrame.maxY - side - 32,
            width: side,
            height: side
        )
    }

    private func savePanelFrame() {
        guard let panel else { return }
        UserDefaults.standard.set(NSStringFromRect(panel.frame), forKey: "WidgetFrame")
    }
}

final class WidgetPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
