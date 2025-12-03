import Foundation

protocol IAppInfo {
    var PackageName: String { get }
    var Name: String { get }
    var VersionString: String { get }
    var Version: VersionInfo { get }
    var BuildString: String { get }
    func ShowSettingsUI()
    var RequestedLayoutDirection: LayoutDirection { get }
}

public enum LayoutDirection {
    case Unknown
    case LeftToRight
    case RightToLeft
}
