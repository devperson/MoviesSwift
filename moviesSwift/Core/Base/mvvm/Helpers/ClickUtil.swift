import Foundation

class ClickUtil
{
    static let OneClickDelay: Int = 1000
    private var lastClickTime: Int64 = 0

    func isOneClick() -> Bool
    {
        let clickTime = Int64(Date().timeIntervalSince1970 * 1000)
        if clickTime - lastClickTime < Int64(ClickUtil.OneClickDelay)
        {
            return false
        }
        lastClickTime = clickTime
        return true
    }
}
