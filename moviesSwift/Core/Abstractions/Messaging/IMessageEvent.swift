import Foundation

protocol IMessageEvent
{
    func Subscribe(_ handler: @escaping (Any?) -> Void) -> UUID
    func Subscribe(_ id: UUID, _ handler: @escaping (Any?) -> Void)
    func Unsubscribe(_ id: UUID)
    func Publish(_ args: Any?)
}
