import Foundation

class UrlNavigationHelper
{
    var isPop: Bool = false
    var isMultiPop: Bool = false
    var isMultiPopAndPush: Bool = false
    var isPush: Bool = false
    var isPushAsRoot: Bool = false
    var isMultiPushAsRoot: Bool = false

    static func Parse(_ url: String) -> UrlNavigationHelper
    {
        let obj = UrlNavigationHelper()

        if url == "../"
        {
            obj.isPop = true
        }
        else if url.contains("../")
        {
            let trimmed = url.replacingOccurrences(of: "../", with: "")
            obj.isMultiPop = trimmed.isEmpty
            obj.isMultiPopAndPush = !obj.isMultiPop
        }
        else if url.contains("/")
        {
            let pages = url.split(separator: "/").filter
            {
                !$0.isEmpty
            }
            if pages.count > 1
            {
                obj.isMultiPushAsRoot = true
            }
            else
            {
                obj.isPushAsRoot = true
            }
        }
        else
        {
            obj.isPush = true
        }

        return obj
    }
}
