actor AsyncSemaphore
{
    private var value: Int
    private var queue: [CheckedContinuation<Void, Never>] = []

    init(value: Int = 1)
    {
        self.value = value
    }

    /// Equivalent to SemaphoreSlim.WaitAsync()
    func WaitAsync() async
    {
        if value > 0
        {
            value -= 1
            //don't lock just continue as it is first thread
            return
        }

        await withCheckedContinuation
        { continuation in
            queue.append(continuation)
        }
    }

    /// Equivalent to SemaphoreSlim.Release()
    func Release()
    {
        if queue.isEmpty == false
        {
            let cont = queue.removeFirst()
            cont.resume()
        }
        else
        {
            value += 1
        }
    }
}
