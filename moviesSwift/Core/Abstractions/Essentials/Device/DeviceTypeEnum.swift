import Foundation

/**
 * Represents the type of device.
 */

public enum DeviceTypeEnum
{
    /**
     * An unknown device type.
     */
    case Unknown

    /**
     * The device is a physical device, such as an iPhone, Android tablet, or Windows/macOS desktop.
     */
    case Physical

    /**
     * The device is virtual, such as the iOS Simulator, Android emulators, or Windows emulators.
     */
    case Virtual
}
