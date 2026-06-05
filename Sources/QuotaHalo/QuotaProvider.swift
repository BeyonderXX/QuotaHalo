import Foundation

struct QuotaProvider {
    private let fileManager = FileManager.default

    var supportDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        return base.appendingPathComponent("QuotaHalo", isDirectory: true)
    }

    var manualUsageURL: URL {
        supportDirectory.appendingPathComponent("usage.json", isDirectory: false)
    }

    var exampleUsageURL: URL {
        supportDirectory.appendingPathComponent("usage.example.json", isDirectory: false)
    }

    func prepareSupportFiles() {
        try? fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
        if !fileManager.fileExists(atPath: exampleUsageURL.path) {
            try? sampleUsageJSON().write(to: exampleUsageURL, atomically: true, encoding: .utf8)
        }
    }

    func ensureManualUsageFile() -> URL {
        prepareSupportFiles()
        if !fileManager.fileExists(atPath: manualUsageURL.path) {
            try? sampleUsageJSON().write(to: manualUsageURL, atomically: true, encoding: .utf8)
        }
        return manualUsageURL
    }

    func fetch() async -> QuotaSnapshot {
        await Task.detached(priority: .utility) {
            do {
                return try AppServerQuotaClient().fetchRateLimits()
            } catch {
                if let manual = readManualUsage(appServerError: error) {
                    return manual
                }
                return QuotaSnapshot.unavailable(error.localizedDescription)
            }
        }.value
    }

    private func sampleUsageJSON() -> String {
        """
        {
          "fiveHour": {
            "remainingPercent": 72,
            "resetAt": "2026-06-06T00:00:00+08:00"
          },
          "weekly": {
            "remainingPercent": 91,
            "resetAt": "2026-06-11T09:00:00+08:00"
          },
          "limitName": "Codex",
          "planType": "pro",
          "source": "manual usage.json"
        }
        """
    }
}

private func readManualUsage(appServerError: Error) -> QuotaSnapshot? {
    let provider = QuotaProvider()
    guard let data = try? Data(contentsOf: provider.manualUsageURL),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }

    let remaining = number(object, "remainingPercent") ?? number(object, "remaining_percent")
    let used = number(object, "usedPercent") ?? number(object, "used_percent")
    let fiveHourWindow = manualWindow(object, keys: ["fiveHour", "five_hour", "primary"], fallbackLabel: "5H")
    let weeklyWindow = manualWindow(object, keys: ["weekly", "week", "secondary"], fallbackLabel: "WEEK")
    guard remaining != nil || used != nil || fiveHourWindow != nil || weeklyWindow != nil else { return nil }

    return QuotaSnapshot(
        status: .manual,
        remainingPercent: remaining ?? fiveHourWindow?.remainingPercent,
        usedPercent: used ?? fiveHourWindow?.usedPercent,
        limitName: string(object, "limitName") ?? string(object, "limit_name") ?? "Codex",
        planType: string(object, "planType") ?? string(object, "plan_type"),
        resetAt: flexibleDate(object["resetAt"] ?? object["reset_at"]) ?? fiveHourWindow?.resetAt,
        updatedAt: Date(),
        source: string(object, "source") ?? "manual usage.json",
        detail: "Codex app-server: \(appServerError.localizedDescription)",
        windowDurationMinutes: integer(object, "windowDurationMinutes") ?? integer(object, "window_duration_minutes") ?? fiveHourWindow?.durationMinutes,
        creditsBalance: string(object, "creditsBalance") ?? string(object, "credits_balance"),
        hasCredits: bool(object, "hasCredits") ?? bool(object, "has_credits"),
        unlimitedCredits: bool(object, "unlimitedCredits") ?? bool(object, "unlimited_credits"),
        rateLimitReachedType: string(object, "rateLimitReachedType") ?? string(object, "rate_limit_reached_type"),
        fiveHourWindow: fiveHourWindow,
        weeklyWindow: weeklyWindow
    )
}

private func manualWindow(_ object: [String: Any], keys: [String], fallbackLabel: String) -> QuotaWindowSnapshot? {
    for key in keys {
        guard let value = object[key] as? [String: Any] else { continue }
        return QuotaWindowSnapshot(
            label: string(value, "label") ?? fallbackLabel,
            remainingPercent: number(value, "remainingPercent") ?? number(value, "remaining_percent"),
            usedPercent: number(value, "usedPercent") ?? number(value, "used_percent"),
            resetAt: flexibleDate(value["resetAt"] ?? value["reset_at"]),
            durationMinutes: integer(value, "durationMinutes") ?? integer(value, "windowDurationMins") ?? integer(value, "duration_minutes")
        )
    }
    return nil
}
