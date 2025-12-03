import Foundation

protocol IDeviceInfo {
    var Model: String { get }
    var Manufacturer: String { get }
    var Name: String { get }
    var VersionString: String { get }
    var Version: VersionInfo { get }
    var Platform: DevicePlatform { get }
    var Idiom: DeviceIdiom { get }
    var DeviceType: DeviceTypeEnum { get }
}


