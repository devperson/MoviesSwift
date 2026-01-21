import Foundation

public struct BrowserLaunchFlags: OptionSet
{
    public let rawValue: Int
    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
    
    public static let PresentAsFormSheet = BrowserLaunchFlags(rawValue: 1 << 0)
    public static let PresentAsPageSheet = BrowserLaunchFlags(rawValue: 1 << 1)
}
