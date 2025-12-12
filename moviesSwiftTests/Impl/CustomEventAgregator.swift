@testable import moviesSwift

import Foundation

class CustomEventAgregator : IMessagesCenter
{
    func GetOrCreateEvent<T: IMessageEvent>(_ eventType: T.Type, factory: () -> T) -> T
    {
        return factory()
    }
}
