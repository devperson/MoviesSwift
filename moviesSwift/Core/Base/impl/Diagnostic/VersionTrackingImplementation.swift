// filepath: /Users/xasan/Documents/GitHub/MoviesSwift/moviesSwift/Core/Base/impl/Diagnostic/VersionTrackingImplementation.swift

import Foundation
import Resolver

class VersionTrackingImplementation: LoggableService, IVersionTracking
{
    @LazyInjected var preferences: IPreferences
    @LazyInjected var appInfo: IAppInfo

    private let versionsKey = "VersionTracking.Versions"
    private let buildsKey = "VersionTracking.Builds"
    private var sharedName: String
    {
        "\(appInfo.PackageName).essentials.versiontracking"
    }

    private var versionTrail: [String: [String]] = [:]

    private var LastInstalledVersion: String
    {
        versionTrail[versionsKey]?.last ?? ""
    }


    private var LastInstalledBuild: String
    {
        versionTrail[buildsKey]?.last ?? ""
    }


    override init()
    {
        super.init()
        do
        {
            try Track()
        }
        catch
        {
            loggingService.TrackError(error)
        }
    }

    func Track() throws
    {
        LogMethodStart(#function)
        if !versionTrail.isEmpty
        {
            return
        }

        try InitVersionTracking()
    }

    internal func InitVersionTracking() throws
    {
        LogMethodStart(#function)
        let isFirst = !(preferences.ContainsKey(versionsKey) && preferences.ContainsKey(buildsKey))
        IsFirstLaunchEver = isFirst

        if IsFirstLaunchEver
        {
            versionTrail = [versionsKey: [], buildsKey: []]
        }
        else
        {
            let versions = try ReadHistory(key: versionsKey)
            let builds = try ReadHistory(key: buildsKey)
            versionTrail = [versionsKey: versions, buildsKey: builds]
        }

        IsFirstLaunchForCurrentVersion = !(versionTrail[versionsKey]?.contains(CurrentVersion) ?? false) || CurrentVersion != LastInstalledVersion
        if IsFirstLaunchForCurrentVersion
        {
            // Avoid duplicates and move current version to end of list if already present
            versionTrail[versionsKey] = (versionTrail[versionsKey] ?? []).filter
            {
                $0 != CurrentVersion
            }
            versionTrail[versionsKey]?.append(CurrentVersion)
        }

        IsFirstLaunchForCurrentBuild = !(versionTrail[buildsKey]?.contains(CurrentBuild) ?? false) || CurrentBuild != LastInstalledBuild
        if IsFirstLaunchForCurrentBuild
        {
            versionTrail[buildsKey] = (versionTrail[buildsKey] ?? []).filter
            {
                $0 != CurrentBuild
            }
            versionTrail[buildsKey]?.append(CurrentBuild)
        }

        if IsFirstLaunchForCurrentVersion || IsFirstLaunchForCurrentBuild
        {
            try WriteHistory(key: versionsKey, history: versionTrail[versionsKey] ?? [])
            try WriteHistory(key: buildsKey, history: versionTrail[buildsKey] ?? [])
        }
    }

    var IsFirstLaunchEver: Bool = false
    private(set) var IsFirstLaunchForCurrentVersion: Bool = false
    private(set) var IsFirstLaunchForCurrentBuild: Bool = false

    var CurrentVersion: String
    {
        appInfo.VersionString
    }
    var CurrentBuild: String
    {
        appInfo.BuildString
    }

    var PreviousVersion: String?
    {
        GetPrevious(key: versionsKey)
    }
    var PreviousBuild: String?
    {
        GetPrevious(key: buildsKey)
    }

    var FirstInstalledVersion: String?
    {
        versionTrail[versionsKey]?.first
    }
    var FirstInstalledBuild: String?
    {
        versionTrail[buildsKey]?.first
    }

    var VersionHistory: [String]
    {
        versionTrail[versionsKey] ?? []
    }
    var BuildHistory: [String]
    {
        versionTrail[buildsKey] ?? []
    }

    func IsFirstLaunchForVersion(_ version: String) -> Bool
    {
        LogMethodStart(#function, version)
        return CurrentVersion == version && IsFirstLaunchForCurrentVersion
    }

    func IsFirstLaunchForBuild(_ build: String) -> Bool
    {
        LogMethodStart(#function, build)
        return CurrentBuild == build && IsFirstLaunchForCurrentBuild
    }

    func GetStatus() -> String
    {
        LogMethodStart(#function)

        var sb: [String] = []
        sb.append("")
        sb.append("VersionTracking")
        sb.append("  IsFirstLaunchEver:              \(IsFirstLaunchEver)")
        sb.append("  IsFirstLaunchForCurrentVersion: \(IsFirstLaunchForCurrentVersion)")
        sb.append("  IsFirstLaunchForCurrentBuild:   \(IsFirstLaunchForCurrentBuild)")
        sb.append("")
        sb.append("  CurrentVersion:                 \(CurrentVersion)")
        sb.append("  PreviousVersion:                \(String(describing: PreviousVersion))")
        sb.append("  FirstInstalledVersion:          \(String(describing: FirstInstalledVersion))")
        sb.append("  VersionHistory:                 [\(VersionHistory.joined(separator: ", "))]")
        sb.append("")
        sb.append("  CurrentBuild:                   \(CurrentBuild)")
        sb.append("  PreviousBuild:                   \(String(describing: PreviousBuild))")
        sb.append("  FirstInstalledBuild:            \(String(describing: FirstInstalledBuild))")
        sb.append("  BuildHistory:                   [\(BuildHistory.joined(separator: ", "))]")

        return sb.joined(separator: "\n")
    }

    private func ReadHistory(key: String) throws-> [String]
    {
        LogMethodStart(#function, key)
        return try preferences.Get(key, defaultValue: nil as String?)?.split(separator: "|").map(String.init).filter
        {
            !$0.isEmpty
        } ?? []
    }

    private func WriteHistory(key: String, history: [String]) throws
    {
        LogMethodStart(#function, key, history)
        try preferences.Set(key, history.joined(separator: "|"))
    }

    private func GetPrevious(key: String) -> String?
    {
        LogMethodStart(#function, key)
        let trail = versionTrail[key] ?? []
        return trail.count >= 2 ? trail[trail.count - 2] : nil
    }
}
