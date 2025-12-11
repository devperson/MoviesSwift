import Foundation

class NavigationParameters: INavigationParameters
{
    private var entries: [(String, Any?)] = []

    init()
    {

    }

    init(key: String, value: Any?)
    {
        Add(key: key, value: value)
    }

    func Add(key: String, value: Any?)
    {
        if let index = entries.firstIndex(where: { $0.0 == key })
        {
            entries[index] = (key, value)
        }
        else
        {
            entries.append((key, value))
        }
    }

    //doesn't force to use the return value (if dev skip the value the warning will not shown)
    @discardableResult
    func With(_ key: String, _ value: Any?) -> NavigationParameters
    {
        Add(key: key, value: value)
        return self
    }

    subscript(key: String) -> Any?
    {
        return entries.first(where: { $0.0 == key })?.1
    }

    func ContainsKey(_ key: String) -> Bool
    {
        entries.contains(where: { $0.0 == key })
    }

    func GetValue<T>(_ key: String) -> T?
    {
        return self[key] as? T
    }

    func Count() -> Int
    {
        entries.count
    }

    func allEntries() -> [(String, Any?)]
    {
        entries
    }
}
