
final class TaskCompletionSource<T> {
    private var continuation: CheckedContinuation<T, Never>?

    var task: Task<T, Never> {
        Task {
            await withCheckedContinuation { cont in
                self.continuation = cont
            }
        }
    }

    func setResult(_ value: T) {
        continuation?.resume(returning: value)
    }
}
