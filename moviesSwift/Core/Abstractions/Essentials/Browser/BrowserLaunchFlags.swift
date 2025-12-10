import Foundation

public struct BrowserLaunchFlags: OptionSet
{
    public let rawValue: Int

    public static let None = BrowserLaunchFlags(rawValue: 0)
    public static let PresentAsFormSheet = BrowserLaunchFlags(rawValue:1)
    public static let PresentAsPageSheet = BrowserLaunchFlags(rawValue:1)

    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
}
