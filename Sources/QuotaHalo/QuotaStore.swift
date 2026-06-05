import Foundation

final class QuotaStore: ObservableObject {
    @Published private(set) var snapshot: QuotaSnapshot = .loading()
    @Published private(set) var isRefreshing = false

    private let provider: QuotaProvider
    private var timer: Timer?

    init(provider: QuotaProvider = QuotaProvider()) {
        self.provider = provider
    }

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.refresh()
            }
            return
        }

        guard !isRefreshing else { return }
        isRefreshing = true

        Task {
            let nextSnapshot = await provider.fetch()
            await MainActor.run {
                snapshot = nextSnapshot
                isRefreshing = false
            }
        }
    }

    func setSnapshotForPreview(_ snapshot: QuotaSnapshot) {
        self.snapshot = snapshot
        self.isRefreshing = false
    }
}
