import Foundation

protocol IDisplay
{
    func GetDisplayInfo() -> DisplayInfo
    func GetDisplayKeepOnValue() -> Bool
    func SetDisplayKeepOnValue(_ keepOn: Bool)
}
