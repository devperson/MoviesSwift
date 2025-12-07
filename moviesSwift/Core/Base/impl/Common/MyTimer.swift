import Foundation

public final class MyTimer
{

    private let Interval: Duration
    private var timer: Timer? = nil

    public let Elapsed = BaseEvent()

    public var IsEnabled: Bool
    {
        return timer != nil && timer!.isValid
    }

    public init(_ interval: Duration)
    {
        self.Interval = interval
    }

    public func Start()
    {
        if IsEnabled
        {
            return
        }

        // Convert Duration → seconds
        let seconds = Interval.timeInterval

        // Use a repeating Timer
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true)
        { [weak self] _ in
            self?.Elapsed.Invoke()
        }

        // Ensure timer stays alive on common run loop
        RunLoop.current.add(timer!, forMode: .common)
    }

    public func Stop()
    {
        timer?.invalidate()
        timer = nil
    }
}


public extension Duration
{
    var timeInterval: TimeInterval
    {
        let c = self.components
        let seconds = Double(c.seconds)
        let attoseconds = Double(c.attoseconds)
        return seconds + attoseconds / 1_000_000_000_000_000_000
    }
}
