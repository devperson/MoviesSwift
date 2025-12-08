import Foundation

/// The Preferences API helps to store application preferences in a key/value store.
public protocol IPreferences
{
    /// Checks for the existence of a given key.
    func ContainsKey(_ key: String) -> Bool

    /// Removes a key and its associated value if it exists.
    func Remove(_ key: String)

    /// Clears all keys and values.
    func Clear()

    /// Sets a value for a given key.
    func Set<T>(_ key: String, _ value: T)

    /// Gets the value for a given key, or the default specified if the key does not exist.
    func Get<T>(_ key: String, defaultValue: T) -> T
}
