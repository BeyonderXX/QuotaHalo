import Foundation

struct AppServerQuotaClient {
    private let timeout: TimeInterval = 18

    func fetchRateLimits() throws -> QuotaSnapshot {
        let payload = try readRateLimitsPayload()
        return try normalize(payload)
    }

    private func readRateLimitsPayload() throws -> [String: Any] {
        let executable = try resolveCodexExecutable()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = ["app-server", "--stdio"]

        let input = Pipe()
        let output = Pipe()
        let standardError = Pipe()
        process.standardInput = input
        process.standardOutput = output
        process.standardError = standardError

        let semaphore = DispatchSemaphore(value: 0)
        let resultLock = NSLock()
        var finalResult: Result<[String: Any], Error>?
        var stdoutBuffer = Data()
        var stderrText = ""

        func complete(_ result: Result<[String: Any], Error>) {
            resultLock.lock()
            if finalResult == nil {
                finalResult = result
                semaphore.signal()
            }
            resultLock.unlock()
        }

        func send(_ message: [String: Any]) throws {
            var data = try JSONSerialization.data(withJSONObject: message)
            data.append(0x0A)
            input.fileHandleForWriting.write(data)
        }

        output.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }

            stdoutBuffer.append(data)
            while let newline = stdoutBuffer.firstIndex(of: 0x0A) {
                let lineData = stdoutBuffer[..<newline]
                stdoutBuffer.removeSubrange(...newline)

                guard !lineData.isEmpty,
                      let message = try? JSONSerialization.jsonObject(with: Data(lineData)) as? [String: Any] else {
                    continue
                }

                if requestID(message["id"]) == 1 {
                    do {
                        try send(["id": 2, "method": "account/rateLimits/read"])
                    } catch {
                        complete(.failure(error))
                    }
                    continue
                }

                if requestID(message["id"]) == 2 {
                    if let error = message["error"] as? [String: Any] {
                        let text = string(error, "message") ?? "Codex app-server returned an error."
                        complete(.failure(QuotaClientError.server(text)))
                    } else if let result = message["result"] as? [String: Any] {
                        complete(.success(result))
                    } else {
                        complete(.failure(QuotaClientError.server("Missing account/rateLimits/read result.")))
                    }
                }
            }
        }

        standardError.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            if stderrText.count < 2_000 {
                stderrText += text
            }
        }

        do {
            try process.run()
            try send([
                "id": 1,
                "method": "initialize",
                "params": [
                    "clientInfo": [
                        "name": "quota-halo",
                        "title": "QuotaHalo",
                        "version": "0.1.0"
                    ],
                    "capabilities": [
                        "experimentalApi": true,
                        "requestAttestation": false,
                        "optOutNotificationMethods": []
                    ]
                ]
            ])
        } catch {
            output.fileHandleForReading.readabilityHandler = nil
            standardError.fileHandleForReading.readabilityHandler = nil
            throw error
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        output.fileHandleForReading.readabilityHandler = nil
        standardError.fileHandleForReading.readabilityHandler = nil

        if process.isRunning {
            process.terminate()
        }

        if waitResult == .timedOut {
            let suffix = stderrText.trimmingCharacters(in: .whitespacesAndNewlines)
            if suffix.isEmpty {
                throw QuotaClientError.timeout
            }
            throw QuotaClientError.timeoutWithContext(suffix)
        }

        switch finalResult {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        case .none:
            throw QuotaClientError.server("No response from Codex app-server.")
        }
    }

    private func normalize(_ payload: [String: Any]) throws -> QuotaSnapshot {
        guard let snapshot = selectCodexSnapshot(from: payload) else {
            throw QuotaClientError.server("No Codex rate-limit snapshot in response.")
        }

        let individual = dictionary(snapshot, "individualLimit")
        let primary = dictionary(snapshot, "primary")
        let secondary = dictionary(snapshot, "secondary")
        let limitingWindow = [primary, secondary]
            .compactMap { $0 }
            .max { (number($0, "usedPercent") ?? -1) < (number($1, "usedPercent") ?? -1) }

        let explicitRemaining = individual.flatMap { number($0, "remainingPercent") }
        let windowUsed = limitingWindow.flatMap { number($0, "usedPercent") }
        let remaining = explicitRemaining ?? windowUsed.map { 100 - $0 }
        let used = explicitRemaining.map { 100 - $0 } ?? windowUsed
        let resetValue = individual.flatMap { number($0, "resetsAt") }
            ?? limitingWindow.flatMap { number($0, "resetsAt") }
        let windows = [primary, secondary].compactMap { $0 }
        let fiveHourWindow = windowSnapshot(
            from: windows.first { integer($0, "windowDurationMins") == 300 } ?? primary,
            label: "5H"
        )
        let weeklyWindow = windowSnapshot(
            from: windows.first { integer($0, "windowDurationMins") == 10_080 } ?? secondary,
            label: "WEEK"
        )

        return QuotaSnapshot(
            status: .ok,
            remainingPercent: remaining.map(QuotaSnapshot.clamp),
            usedPercent: used.map(QuotaSnapshot.clamp),
            limitName: string(snapshot, "limitName")
                ?? individual.flatMap { string($0, "limit") }
                ?? "Codex",
            planType: string(snapshot, "planType"),
            resetAt: epochDate(resetValue),
            updatedAt: Date(),
            source: "Codex app-server",
            detail: detailText(snapshot: snapshot, window: limitingWindow),
            windowDurationMinutes: limitingWindow.flatMap { integer($0, "windowDurationMins") },
            creditsBalance: dictionary(snapshot, "credits").flatMap { string($0, "balance") },
            hasCredits: dictionary(snapshot, "credits").flatMap { bool($0, "hasCredits") },
            unlimitedCredits: dictionary(snapshot, "credits").flatMap { bool($0, "unlimited") },
            rateLimitReachedType: string(snapshot, "rateLimitReachedType"),
            fiveHourWindow: fiveHourWindow,
            weeklyWindow: weeklyWindow
        )
    }

    private func windowSnapshot(from payload: [String: Any]?, label: String) -> QuotaWindowSnapshot? {
        guard let payload else { return nil }
        let used = number(payload, "usedPercent")
        let remaining = used.map { 100 - $0 }
        return QuotaWindowSnapshot(
            label: label,
            remainingPercent: remaining.map(QuotaSnapshot.clamp),
            usedPercent: used.map(QuotaSnapshot.clamp),
            resetAt: epochDate(number(payload, "resetsAt")),
            durationMinutes: integer(payload, "windowDurationMins")
        )
    }

    private func selectCodexSnapshot(from payload: [String: Any]) -> [String: Any]? {
        if let byID = payload["rateLimitsByLimitId"] as? [String: Any] {
            if let codex = byID["codex"] as? [String: Any] {
                return codex
            }

            for (key, value) in byID where key.lowercased().contains("codex") {
                if let snapshot = value as? [String: Any] {
                    return snapshot
                }
            }
        }

        if let rateLimits = payload["rateLimits"] as? [String: Any] {
            return rateLimits
        }

        return nil
    }

    private func resolveCodexExecutable() throws -> String {
        let environmentPath = ProcessInfo.processInfo.environment["CODEX_QUOTA_CODEX_PATH"]
        let candidates = [
            environmentPath,
            "/Applications/Codex.app/Contents/Resources/codex",
            "/opt/homebrew/bin/codex",
            "/usr/local/bin/codex",
            "/usr/bin/codex"
        ].compactMap { $0 }

        for path in candidates where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }

        throw QuotaClientError.server("Cannot find the Codex executable.")
    }

    private func detailText(snapshot: [String: Any], window: [String: Any]?) -> String? {
        if let reached = string(snapshot, "rateLimitReachedType") {
            return reached
        }

        if let minutes = window.flatMap({ integer($0, "windowDurationMins") }) {
            return "窗口 \(minutes) 分钟"
        }

        if dictionary(snapshot, "credits").flatMap({ bool($0, "unlimited") }) == true {
            return "Credits unlimited"
        }

        return nil
    }
}

enum QuotaClientError: LocalizedError {
    case timeout
    case timeoutWithContext(String)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Codex app-server timed out."
        case .timeoutWithContext(let context):
            return "Codex app-server timed out: \(context)"
        case .server(let message):
            return message
        }
    }
}
