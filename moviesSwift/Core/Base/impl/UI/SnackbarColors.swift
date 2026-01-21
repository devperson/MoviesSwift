import Foundation

enum SnackbarColors
{

    static var InfoColor: XfColor = XfColor.FromHex("#E1F0FF")
    static var InfoTextColor: XfColor = XfColor.FromHex("#FFF9F9FA")

    static var ErrorColor: XfColor = XfColor.FromHex("#FFEAEB")
    static var ErrorTextColor: XfColor = XfColor.FromHex("#ff4444")

    static var SuccessColor: XfColor = XfColor.FromHex("#FFCDFFCD")
    static var SuccessTextColor: XfColor = XfColor.FromHex("#FF114338")

    static func GetBackgroundColor(for severity: SeverityType) -> XfColor
    {
        switch severity
        {
            case .Info:
                return InfoColor
            case .Error, .Warning:
                return ErrorColor
            default:
                return SuccessColor
        }
    }

    static func GetTextColor(for severity: SeverityType) -> XfColor
    {
        switch severity
        {
            case .Info:
                return InfoTextColor
            case .Error, .Warning:
                return ErrorTextColor
            default:
                return SuccessTextColor
        }
    }
}

