import Foundation

open class SubMessage: IMessageEvent
{
    private var handlers: [(Any?) -> Void] = []
    private let queue = DispatchQueue(label: "SimpleMessagingCenter.SubMessage")

    public func Subscribe(_ handler: @escaping (Any?) -> Void)
    {
        queue.sync {
            // naive contains check; closures can't be equated by value in Swift
            handlers.append(handler)
        }
    }

    public func Unsubscribe(_ handler: @escaping (Any?) -> Void)
    {
        queue.sync {
            // not straightforward to remove identical closure; left as no-op for now or users should manage tokens
        }
    }

    public func Publish(_ args: Any?)
    {
        let snapshot: [(Any?) -> Void] = queue.sync { handlers }
        snapshot.forEach { $0(args) }
    }
}

class SimpleMessageCenter: IMessagesCenter
{
    private var events: [ObjectIdentifier: Any] = [:]
    private let queue = DispatchQueue(label: "SimpleMessagingCenter.events")

    func GetOrCreateEvent<TEvent: IMessageEvent>(_ eventType: TEvent.Type, factory: () -> TEvent) -> TEvent
    {
        return queue.sync
        {
            let key = ObjectIdentifier(eventType)
            if let existing = events[key] as? TEvent {
                return existing
            }
            let newInstance = factory()
            events[key] = newInstance
            return newInstance
        }
    }
}

extension IMessagesCenter
{
    func GetEvent<TEvent: IMessageEvent>(_ factory: @escaping () -> TEvent) -> TEvent
    {
        return GetOrCreateEvent(TEvent.self, factory: factory)
    }
}

