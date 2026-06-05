import SwiftUI

struct SetupWindowView: View {
    @ObservedObject var settings: SettingsStore
    var onOpenCodexApp: () -> Void
    var onStartLogin: () -> Void
    var onRefresh: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.cyan.opacity(0.16))
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.cyan)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 3) {
                    Text(settings.text(.setupTitle))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(settings.text(.setupSubtitle))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            setupRow(icon: "shippingbox.fill", title: settings.text(.setupStepInstallTitle), body: settings.text(.setupStepInstallBody))
            setupRow(icon: "person.crop.circle.badge.checkmark", title: settings.text(.setupStepLoginTitle), body: settings.text(.setupStepLoginBody))
            setupRow(icon: "arrow.triangle.2.circlepath", title: settings.text(.setupStepUseTitle), body: settings.text(.setupStepUseBody))

            HStack(spacing: 10) {
                Button(action: onOpenCodexApp) {
                    Label(settings.text(.openCodexApp), systemImage: "app.dashed")
                }
                Button(action: onStartLogin) {
                    Label(settings.text(.startCodexLogin), systemImage: "key.fill")
                }
                Button(action: onRefresh) {
                    Label(settings.text(.refreshQuota), systemImage: "arrow.clockwise")
                }
                Spacer()
                Button(settings.text(.close), action: onClose)
            }
            .buttonStyle(.bordered)
        }
        .padding(22)
        .frame(width: 560)
    }

    private func setupRow(icon: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.cyan)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text(body)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
