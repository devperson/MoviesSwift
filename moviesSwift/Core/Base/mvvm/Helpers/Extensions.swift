import Foundation

extension Array
{
    func ToDebugString() -> String
    {
        var sb = "List[\(self.count)] "
        for item in self
        {
            sb += "\(item), "
        }
        return sb
    }
}
