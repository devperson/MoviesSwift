import Foundation

open class BaseEvent
{
    private var handlers: [Entry] = []

    func AddListener(_ handler: @escaping () -> Void) -> UUID
    {
        let id = UUID()
        handlers.append(.init(id: id, handler: handler))
        return id
    }

    func RemoveListener(_ id: UUID)
    {
        handlers.removeAll { $0.id == id }
    }

    func Invoke()
    {
        let copy = handlers;
        copy.forEach { $0.handler() }
    }
}

class Event<T>: BaseEvent
{
    private var handlersWithArg: [EntryTyped<T>] = []

    func AddListener(_ handler: @escaping (T) -> Void) -> UUID
    {
        let id = UUID()
        handlersWithArg.append(.init(id: id, handler: handler))
        return id
    }

    override func RemoveListener(_ id: UUID)
    {
        handlersWithArg.removeAll { $0.id == id }
    }

    func Invoke(_ value: T)
    {
        let copy = handlersWithArg;
        copy.forEach { $0.handler(value) }
    }
}

private struct Entry
{
    let id: UUID
    let handler: () -> Void
}

private struct EntryTyped<T>
{
    let id: UUID
    let handler: (T) -> Void
}
