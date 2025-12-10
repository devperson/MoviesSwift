import Foundation
  
import UIKit

class iOSDeviceInfoImplementation: IDeviceInfo {
    var Model: String {
        return UIDevice.current.model
    }

    var Manufacturer: String {
        return "Apple"
    }

    var Name: String {
        return UIDevice.current.name
    }

    var VersionString: String {
        return UIDevice.current.systemVersion
    }

    var Version: VersionInfo
    {
        return VersionInfo.ParseVersion(VersionString)
    }

    var Platform: DevicePlatform
    {
        return DevicePlatform.iOS
    }

    var Idiom: DeviceIdiom {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return DeviceIdiom.Tablet
        case .phone:
            return DeviceIdiom.Phone
        case .tv:
            return DeviceIdiom.TV
        case .carPlay, .unspecified:
            fallthrough
        default:
            return DeviceIdiom.Unknown
        }
    }

    var DeviceType: DeviceTypeEnum {
        // Placeholder logic; replace if simulator detection is added later
        return DeviceTypeEnum.Physical
    }
}
