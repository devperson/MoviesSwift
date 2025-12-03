import Foundation

protocol IMessageEvent {
    func Subscribe(_ handler: @escaping (Any?) -> Void)
    func Unsubscribe(_ handler: @escaping (Any?) -> Void)
    func Publish(_ args: Any?)
}
