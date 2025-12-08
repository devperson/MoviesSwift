import Foundation

public struct BrowserLaunchFlags: OptionSet
{
    public let rawValue: Int

    public static let None = BrowserLaunchFlags(rawValue: 0)

    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
}
