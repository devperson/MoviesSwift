import Foundation

protocol INavigationParameters
{
    func ContainsKey(_ key: String) -> Bool
    func GetValue<T>(_ key: String) -> T?
    func Count() -> Int
}
