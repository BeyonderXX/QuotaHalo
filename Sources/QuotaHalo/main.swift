import AppKit
import Foundation
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

private func runQuotaCLI() {
    let semaphore = DispatchSemaphore(value: 0)
    var exitCode: Int32 = 0

    Task {
        let snapshot = await QuotaProvider().fetch()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        if let data = try? encoder.encode(snapshot),
           let text = String(data: data, encoding: .utf8) {
            print(text)
        } else {
            fputs("Failed to encode quota snapshot.\n", stderr)
            exitCode = 1
        }

        if snapshot.status == .error || snapshot.status == .unavailable {
            exitCode = 2
        }
        semaphore.signal()
    }

    semaphore.wait()
    Foundation.exit(exitCode)
}

if CommandLine.arguments.contains("--print-quota") {
    runQuotaCLI()
}

@MainActor
private func renderPreview(path: String, language: AppLanguage?) async -> Int32 {
    let snapshot = await QuotaProvider().fetch()
    let store = QuotaStore()
    let settings = SettingsStore()
    if let language {
        settings.language = language
    }
    store.setSnapshotForPreview(snapshot)

    let view = ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.07, blue: 0.09),
                Color(red: 0.10, green: 0.12, blue: 0.15),
                Color(red: 0.03, green: 0.08, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.cyan.opacity(0.24))
                .frame(width: 160, height: 160)
                .blur(radius: 46)
                .offset(x: 42, y: -34)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(.mint.opacity(0.18))
                .frame(width: 130, height: 130)
                .blur(radius: 42)
                .offset(x: -34, y: 36)
        }

        QuotaWidgetView(store: store, settings: settings)
            .padding(42)
    }
    .frame(width: 288, height: 288)

    let renderer = ImageRenderer(content: view)
    renderer.scale = 2

    guard let image = renderer.cgImage else {
        fputs("Failed to render preview image.\n", stderr)
        return 1
    }

    let url = URL(fileURLWithPath: path) as CFURL
    guard let destination = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else {
        fputs("Failed to create preview image destination.\n", stderr)
        return 1
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        fputs("Failed to write preview image.\n", stderr)
        return 1
    }
    print(path)
    return 0
}

if let index = CommandLine.arguments.firstIndex(of: "--render-preview") {
    let outputPath = CommandLine.arguments.dropFirst(index + 1).first ?? "/private/tmp/codex-quota-preview.png"
    let language: AppLanguage?
    if let languageIndex = CommandLine.arguments.firstIndex(of: "--language"),
       let rawLanguage = CommandLine.arguments.dropFirst(languageIndex + 1).first {
        language = AppLanguage(rawValue: rawLanguage)
    } else {
        language = nil
    }
    var exitCode: Int32 = 0
    var isDone = false
    Task { @MainActor in
        exitCode = await renderPreview(path: outputPath, language: language)
        isDone = true
    }
    while !isDone {
        RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.05))
    }
    Foundation.exit(exitCode)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
