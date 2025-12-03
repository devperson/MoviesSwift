import Foundation

/// The VersionTracking API provides an easy way to track an app's version on a device.
public protocol IVersionTracking {
    /// Starts tracking version information.
    func Track()

    /// Gets a value indicating whether this is the first time this app has ever been launched on this device.
    var IsFirstLaunchEver: Bool { get }

    /// Gets a value indicating if this is the first launch of the app for the current version number.
    var IsFirstLaunchForCurrentVersion: Bool { get }

    /// Gets a value indicating if this is the first launch of the app for the current build number.
    var IsFirstLaunchForCurrentBuild: Bool { get }

    /// Gets the current version number of the app.
    var CurrentVersion: String { get }

    /// Gets the current build of the app.
    var CurrentBuild: String { get }

    /// Gets the version number for the previously run version.
    var PreviousVersion: String? { get }

    /// Gets the build number for the previously run version.
    var PreviousBuild: String? { get }

    /// Gets the version number of the first version of the app that was installed on this device.
    var FirstInstalledVersion: String? { get }

    /// Gets the build number of first version of the app that was installed on this device.
    var FirstInstalledBuild: String? { get }

    /// Gets the collection of version numbers of the app that ran on this device.
    var VersionHistory: [String] { get }

    /// Gets the collection of build numbers of the app that ran on this device.
    var BuildHistory: [String] { get }

    /// Determines if this is the first launch of the app for a specified version number.
    func IsFirstLaunchForVersion(_ version: String) -> Bool

    /// Determines if this is the first launch of the app for a specified build number.
    func IsFirstLaunchForBuild(_ build: String) -> Bool
}
