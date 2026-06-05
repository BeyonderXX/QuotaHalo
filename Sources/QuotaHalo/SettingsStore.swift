import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .simplifiedChinese:
            return "中文"
        }
    }
}

final class SettingsStore: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
        }
    }

    private static let languageKey = "AppLanguage"

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.languageKey),
           let stored = AppLanguage(rawValue: raw) {
            self.language = stored
        } else {
            self.language = .english
        }
    }

    func text(_ key: AppTextKey) -> String {
        AppText.value(key, language: language)
    }
}

enum AppTextKey {
    case quota5h
    case quotaWeekly
    case waitingReset
    case today
    case tomorrow
    case syncing
    case local
    case refreshNow
    case showHide
    case keepOnTop
    case openUsagePage
    case openManualJSON
    case setup
    case setupTitle
    case setupSubtitle
    case setupStepInstallTitle
    case setupStepInstallBody
    case setupStepLoginTitle
    case setupStepLoginBody
    case setupStepUseTitle
    case setupStepUseBody
    case openCodexApp
    case startCodexLogin
    case refreshQuota
    case close
    case language
    case quit
}

enum AppText {
    static func value(_ key: AppTextKey, language: AppLanguage) -> String {
        switch language {
        case .english:
            return english(key)
        case .simplifiedChinese:
            return chinese(key)
        }
    }

    private static func english(_ key: AppTextKey) -> String {
        switch key {
        case .quota5h:
            return "Every 5h"
        case .quotaWeekly:
            return "Weekly"
        case .waitingReset:
            return "Waiting for reset"
        case .today:
            return "Today"
        case .tomorrow:
            return "Tomorrow"
        case .syncing:
            return "SYNCING"
        case .local:
            return "LOCAL"
        case .refreshNow:
            return "Refresh Now"
        case .showHide:
            return "Show/Hide"
        case .keepOnTop:
            return "Keep on Top"
        case .openUsagePage:
            return "Open Codex Usage"
        case .openManualJSON:
            return "Open Manual JSON"
        case .setup:
            return "Setup..."
        case .setupTitle:
            return "QuotaHalo Setup"
        case .setupSubtitle:
            return "Use the official Codex login. This app never stores tokens."
        case .setupStepInstallTitle:
            return "1. Install Codex"
        case .setupStepInstallBody:
            return "Install or open the official Codex app/CLI first."
        case .setupStepLoginTitle:
            return "2. Sign in"
        case .setupStepLoginBody:
            return "Start the official Codex login flow. A Terminal window may open."
        case .setupStepUseTitle:
            return "3. Refresh"
        case .setupStepUseBody:
            return "After login finishes, refresh the widget."
        case .openCodexApp:
            return "Open Codex App"
        case .startCodexLogin:
            return "Start Codex Login"
        case .refreshQuota:
            return "Refresh Quota"
        case .close:
            return "Close"
        case .language:
            return "Language"
        case .quit:
            return "Quit"
        }
    }

    private static func chinese(_ key: AppTextKey) -> String {
        switch key {
        case .quota5h:
            return "每 5 小时"
        case .quotaWeekly:
            return "每周"
        case .waitingReset:
            return "等待重置时间"
        case .today:
            return "今天"
        case .tomorrow:
            return "明天"
        case .syncing:
            return "同步中"
        case .local:
            return "本地"
        case .refreshNow:
            return "立即刷新"
        case .showHide:
            return "显示/隐藏"
        case .keepOnTop:
            return "保持在最前"
        case .openUsagePage:
            return "打开 Codex 用量页"
        case .openManualJSON:
            return "打开手动数据 JSON"
        case .setup:
            return "设置..."
        case .setupTitle:
            return "QuotaHalo 设置"
        case .setupSubtitle:
            return "使用官方 Codex 登录。本应用不会保存 token。"
        case .setupStepInstallTitle:
            return "1. 安装 Codex"
        case .setupStepInstallBody:
            return "请先安装或打开官方 Codex app/CLI。"
        case .setupStepLoginTitle:
            return "2. 登录"
        case .setupStepLoginBody:
            return "启动官方 Codex 登录流程。可能会打开 Terminal。"
        case .setupStepUseTitle:
            return "3. 刷新"
        case .setupStepUseBody:
            return "登录完成后刷新小组件。"
        case .openCodexApp:
            return "打开 Codex App"
        case .startCodexLogin:
            return "启动 Codex 登录"
        case .refreshQuota:
            return "刷新余量"
        case .close:
            return "关闭"
        case .language:
            return "语言"
        case .quit:
            return "退出"
        }
    }
}
