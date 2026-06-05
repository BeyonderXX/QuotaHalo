import SwiftUI

struct QuotaWidgetView: View {
    @ObservedObject var store: QuotaStore
    @ObservedObject var settings: SettingsStore

    var body: some View {
        ZStack {
            GlassBackground()

            VStack(alignment: .leading, spacing: 12) {
                header
                QuotaLineView(
                    icon: "clock.fill",
                    title: settings.text(.quota5h),
                    accent: fiveHourColor,
                    window: store.snapshot.fiveHourDisplay,
                    settings: settings
                )
                QuotaLineView(
                    icon: "calendar",
                    title: settings.text(.quotaWeekly),
                    accent: weeklyColor,
                    window: store.snapshot.weeklyDisplay,
                    settings: settings
                )
                footer
            }
            .padding(16)
        }
        .frame(width: 204, height: 204)
        .fixedSize()
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .environment(\.colorScheme, .dark)
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white.opacity(0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.26), lineWidth: 0.8)
                    )
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.cyan)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                Text("Codex")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(planText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.16), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: CGFloat((store.snapshot.fiveHourDisplay?.normalizedRemaining ?? 0) / 100))
                    .stroke(fiveHourColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: store.isRefreshing ? "arrow.triangle.2.circlepath" : "bolt.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(fiveHourColor)
            }
            .frame(width: 30, height: 30)
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: statusIcon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(statusColor)
            Text(sourceText)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.top, 2)
    }

    private var statusColor: Color {
        guard let remaining = store.snapshot.fiveHourDisplay?.normalizedRemaining else {
            return store.isRefreshing ? .cyan : .secondary
        }
        switch remaining {
        case 50...100:
            return .mint
        case 20..<50:
            return .yellow
        default:
            return .red
        }
    }

    private var fiveHourColor: Color {
        statusColor
    }

    private var weeklyColor: Color {
        guard let remaining = store.snapshot.weeklyDisplay?.normalizedRemaining else { return .cyan }
        return remaining < 20 ? .orange : .cyan
    }

    private var statusIcon: String {
        switch store.snapshot.status {
        case .ok:
            return "checkmark.seal.fill"
        case .manual:
            return "doc.text.fill"
        case .error, .unavailable:
            return "exclamationmark.triangle.fill"
        }
    }

    private var planText: String {
        if let plan = store.snapshot.planType, !plan.isEmpty {
            return plan.uppercased()
        }
        return store.isRefreshing ? settings.text(.syncing) : settings.text(.local)
    }

    private var sourceText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(store.snapshot.source)  \(formatter.string(from: store.snapshot.updatedAt))"
    }
}

private struct QuotaLineView: View {
    var icon: String
    var title: String
    var accent: Color
    var window: QuotaWindowSnapshot?
    @ObservedObject var settings: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(accent)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(resetText)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(percentText)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.13))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.72), accent, .white.opacity(0.76)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geometry.size.width * progress))
                        .shadow(color: accent.opacity(0.45), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 7)
        }
        .padding(.vertical, 3)
    }

    private var percentText: String {
        guard let remaining = window?.normalizedRemaining else { return "--%" }
        return "\(Int(remaining.rounded()))%"
    }

    private var progress: CGFloat {
        CGFloat((window?.normalizedRemaining ?? 0) / 100)
    }

    private var resetText: String {
        guard let resetAt = window?.resetAt else { return settings.text(.waitingReset) }
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        if calendar.isDateInToday(resetAt) {
            return settings.text(.today) + " " + timeFormatter.string(from: resetAt)
        }
        if calendar.isDateInTomorrow(resetAt) {
            return settings.text(.tomorrow) + " " + timeFormatter.string(from: resetAt)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: resetAt)
    }
}

private struct GlassBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(.ultraThinMaterial.opacity(0.10))
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(.black.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.08),
                                .cyan.opacity(0.04),
                                .black.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.58),
                                .white.opacity(0.14),
                                .cyan.opacity(0.20),
                                .black.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.1
                    )
            )
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(.white.opacity(0.28), lineWidth: 0.6)
                    .padding(1)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
            }
            .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 14)
    }
}
