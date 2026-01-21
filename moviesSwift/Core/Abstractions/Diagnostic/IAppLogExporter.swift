import Foundation

protocol IAppLogExporter
{
    func ShareLogs() async throws -> LogSharingResult
}

public struct LogSharingResult
{
    public let Success: Bool
    public let Exception: Error?

    public init(Success: Bool, Exception: Error? = nil)
    {
        self.Success = Success
        self.Exception = Exception
    }
}
