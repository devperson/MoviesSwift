import Foundation

open class SubMessage: IMessageEvent
{
    private var handlers: [UUID : (Any?) -> Void] = [:]
    private let queue = DispatchQueue(label: "SimpleMessagingCenter.SubMessage")

    public func Subscribe(_ handler: @escaping (Any?) -> Void) -> UUID
    {
        let id = UUID()
        queue.sync
        {            
            handlers[id] = handler
        }
        return id
    }
    
    public func Subscribe(_ id: UUID,  _ handler: @escaping (Any?) -> Void)
    {
        queue.sync
        {
            handlers[id] = handler
        }
    }

    public func Unsubscribe(_ id: UUID)
    {
        _ = queue.sync
        {
            handlers.removeValue(forKey: id)
        }
    }

    public func Publish(_ args: Any?)
    {
        let snapshot = queue.sync { handlers }
        snapshot.forEach { $0.value(args) }
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

