import Foundation

struct QuotaWindowSnapshot: Codable, Equatable {
    var label: String
    var remainingPercent: Double?
    var usedPercent: Double?
    var resetAt: Date?
    var durationMinutes: Int?

    var normalizedRemaining: Double? {
        if let remainingPercent {
            return QuotaSnapshot.clamp(remainingPercent)
        }
        if let usedPercent {
            return QuotaSnapshot.clamp(100 - usedPercent)
        }
        return nil
    }

    var normalizedUsed: Double? {
        if let usedPercent {
            return QuotaSnapshot.clamp(usedPercent)
        }
        if let remainingPercent {
            return QuotaSnapshot.clamp(100 - remainingPercent)
        }
        return nil
    }
}

struct QuotaSnapshot: Codable, Equatable {
    enum Status: String, Codable {
        case ok
        case manual
        case error
        case unavailable
    }

    var status: Status
    var remainingPercent: Double?
    var usedPercent: Double?
    var limitName: String
    var planType: String?
    var resetAt: Date?
    var updatedAt: Date
    var source: String
    var detail: String?
    var windowDurationMinutes: Int?
    var creditsBalance: String?
    var hasCredits: Bool?
    var unlimitedCredits: Bool?
    var rateLimitReachedType: String?
    var fiveHourWindow: QuotaWindowSnapshot?
    var weeklyWindow: QuotaWindowSnapshot?

    static func loading() -> QuotaSnapshot {
        QuotaSnapshot(
            status: .unavailable,
            remainingPercent: nil,
            usedPercent: nil,
            limitName: "Codex",
            planType: nil,
            resetAt: nil,
            updatedAt: Date(),
            source: "Codex app-server",
            detail: "正在读取",
            windowDurationMinutes: nil,
            creditsBalance: nil,
            hasCredits: nil,
            unlimitedCredits: nil,
            rateLimitReachedType: nil,
            fiveHourWindow: nil,
            weeklyWindow: nil
        )
    }

    static func unavailable(_ detail: String, source: String = "Codex app-server") -> QuotaSnapshot {
        QuotaSnapshot(
            status: .unavailable,
            remainingPercent: nil,
            usedPercent: nil,
            limitName: "Codex",
            planType: nil,
            resetAt: nil,
            updatedAt: Date(),
            source: source,
            detail: detail,
            windowDurationMinutes: nil,
            creditsBalance: nil,
            hasCredits: nil,
            unlimitedCredits: nil,
            rateLimitReachedType: nil,
            fiveHourWindow: nil,
            weeklyWindow: nil
        )
    }

    var normalizedRemaining: Double? {
        if let remainingPercent {
            return Self.clamp(remainingPercent)
        }
        if let usedPercent {
            return Self.clamp(100 - usedPercent)
        }
        return nil
    }

    var fiveHourDisplay: QuotaWindowSnapshot? {
        if let fiveHourWindow {
            return fiveHourWindow
        }
        guard remainingPercent != nil || usedPercent != nil else { return nil }
        return QuotaWindowSnapshot(
            label: "5H",
            remainingPercent: remainingPercent,
            usedPercent: usedPercent,
            resetAt: resetAt,
            durationMinutes: windowDurationMinutes
        )
    }

    var weeklyDisplay: QuotaWindowSnapshot? {
        weeklyWindow
    }

    var normalizedUsed: Double? {
        if let usedPercent {
            return Self.clamp(usedPercent)
        }
        if let remainingPercent {
            return Self.clamp(100 - remainingPercent)
        }
        return nil
    }

    static func clamp(_ value: Double) -> Double {
        min(100, max(0, value))
    }
}
