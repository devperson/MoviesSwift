import Foundation

public struct VersionInfo: Comparable, Equatable
{
    public let major: Int
    public let minor: Int
    public let build: Int
    public let revision: Int

    public init(major: Int, minor: Int, build: Int = -1, revision: Int = -1)
    {
        precondition(major >= 0, "Major version cannot be negative.")
        precondition(minor >= 0, "Minor version cannot be negative.")
        if build != -1
        {
            precondition(build >= 0, "Build cannot be negative.")
        }
        if revision != -1
        {
            precondition(revision >= 0, "Revision cannot be negative.")
        }
        self.major = major
        self.minor = minor
        self.build = build
        self.revision = revision
    }

    public var majorRevision: Int16
    {
        Int16((revision >> 16) & 0xFFFF)
    }
    public var minorRevision: Int16
    {
        Int16(revision & 0xFFFF)
    }

    public static func <(lhs: VersionInfo, rhs: VersionInfo) -> Bool
    {
        if lhs.major != rhs.major
        {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor
        {
            return lhs.minor < rhs.minor
        }
        if lhs.build != rhs.build
        {
            return lhs.build < rhs.build
        }
        if lhs.revision != rhs.revision
        {
            return lhs.revision < rhs.revision
        }
        return false
    }

    public func toString() -> String
    {
        var parts: [Int] = [major, minor]
        if build >= 0
        {
            parts.append(build)
        }
        if revision >= 0
        {
            parts.append(revision)
        }
        return parts.map
        {
            String($0)
        }
        .joined(separator: ".")
    }

    public static func ParseVersion(_ version: String) -> VersionInfo
    {
        if let parsed = tryParse(version)
        {
            return parsed
        }
        if let major = Int(version)
        {
            return VersionInfo(major: major, minor: 0)
        }
        return VersionInfo(major: 0, minor: 0)
    }

    public static func parse(_ input: String) -> VersionInfo
    {
        let s = input.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(!s.isEmpty, "Input cannot be blank")
        let parts = s.split(separator: ".").map(String.init)
        precondition(parts.count >= 2 && parts.count <= 4, "Invalid version format: \(input)")

        func parsePart(_ s: String, name: String) -> Int
        {
            guard let v = Int(s), v >= 0
            else
            {
                fatalError("Invalid number in version part: \(name) = \(s)")
            }
            return v
        }

        let major = parsePart(parts[0], name: "major")
        let minor = parsePart(parts[1], name: "minor")
        let build = parts.count >= 3 ? parsePart(parts[2], name: "build") : -1
        let revision = parts.count == 4 ? parsePart(parts[3], name: "revision") : -1
        return VersionInfo(major: major, minor: minor, build: build, revision: revision)
    }

    public static func tryParse(_ input: String?) -> VersionInfo?
    {
        guard let input = input
        else
        {
            return nil
        }
        return VersionInfo.parse(input)
    }
}

public func ==(lhs: VersionInfo, rhs: VersionInfo) -> Bool
{
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.build == rhs.build && lhs.revision == rhs.revision
}

public func compareNullable(_ lhs: VersionInfo?, _ rhs: VersionInfo?) -> Int
{
    if lhs == nil
    {
        return rhs == nil ? 0 : -1
    }
    if rhs == nil
    {
        return 1
    }
    if lhs! < rhs!
    {
        return -1
    }
    if lhs! > rhs!
    {
        return 1
    }
    return 0
}
