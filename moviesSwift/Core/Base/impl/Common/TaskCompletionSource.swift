final class TaskCompletionSource<T>
{
    private var continuation: CheckedContinuation<T, Error>?

    var task: Task<T, Error>
    {
        Task
        {
            try await withCheckedThrowingContinuation
            { cont in
                self.continuation = cont
            }
        }
    }

    func setResult(_ value: T)
    {
        continuation?.resume(returning: value)
    }

    func setError(_ error: Error)
    {
        continuation?.resume(throwing: error)
    }
}
