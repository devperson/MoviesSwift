import Foundation
import Resolver

class AppLogExporter: LoggableService, IAppLogExporter
{
    @LazyInjected var directoryService: IDirectoryService
    @LazyInjected var shareFileService: IShare

    private let KyChat_Logs = "KyChat_Logs"

    
    func ShareLogs() async -> LogSharingResult
    {
        LogMethodStart(#function)

        // remove old files
        removeOldFilesFromCache()

        let date = getUtcDateString()
        let fileName = "\(KyChat_Logs)_\(date).zip"

        let cacheDirPath = directoryService.GetCacheDir()
        let fileUrl = URL(fileURLWithPath: cacheDirPath).appendingPathComponent(fileName)

        // also include censored database into logs folder.
        // this.CopyCensoredDatabaseAsync()

        // try to get compressed logs from logging service
        let compressedLogs = await loggingService.GetCompressedLogFileBytes(getOnlyLastSession: true)

        if compressedLogs == nil
        {
            let nsErr = NSError(domain: "AppLogExporter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: GetCompressedLogFileBytes() method returned nil."])
            return LogSharingResult(Success: false, Exception: nsErr)
        }

        do
        {
            try compressedLogs!.write(to: fileUrl)
        }
        catch
        {
            loggingService.TrackError(error, data: nil)
            return LogSharingResult(Success: false, Exception: error)
        }

        shareFileService.RequestShareFile(title: "Sharing compressed logs", fullPath: fileUrl.path)

        return LogSharingResult(Success: true, Exception: nil)
    }

    func removeOldFilesFromCache()
    {
        LogMethodStart(#function)

        let fm = FileManager.default
        let cacheDirPath = directoryService.GetCacheDir()
        do
        {
            let items = try fm.contentsOfDirectory(atPath: cacheDirPath)
            for item in items where item.contains(KyChat_Logs)
            {
                let full = URL(fileURLWithPath: cacheDirPath).appendingPathComponent(item).path
                try fm.removeItem(atPath: full)
            }
        }
        catch
        {
            loggingService.TrackError(error, data: nil)
        }
    }

    func getUtcDateString() -> String
    {
        LogMethodStart(#function)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: Date())
    }

}
