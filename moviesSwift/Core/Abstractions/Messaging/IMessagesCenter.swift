import Foundation

protocol IMessagesCenter
{
    func GetOrCreateEvent<T: IMessageEvent>(_ eventType: T.Type, factory: () -> T) -> T
}

extension IMessagesCenter
{
    func GetEvent<T: IMessageEvent>(factory: () -> T) -> T
    {
        return GetOrCreateEvent(T.self, factory: factory)
    }
}
