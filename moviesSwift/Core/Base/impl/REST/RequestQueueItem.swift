//
//  RequestQueueItem.swift
//  moviesSwift
//
//  Created by xasan on 06/12/25.
//


import Foundation

internal class RequestQueueItem {

    // MARK: - Properties

    var startedAt: Date = Date()

    weak var parentList: RequestQueueList?
    var Id: String = ""
    var RequestAction: (() async throws -> String)?
    var priority: Priority = .Normal

    // Kotlin: CompletableDeferred<String>
    let CompletionSource = TaskCompletionSource<String>()

    var timeoutType: TimeoutType = .Medium
    var logger: ILoggingService? = nil
    var IsCompleted: Bool = false
    var IsRunning: Bool = false
    var result: String? = nil

    // MARK: - Timeout Mapping

    var TimeOut: Int {
        switch timeoutType {
        case .High:
            return TimeoutType.High.rawValue + 5
        case .VeryHigh:
            return TimeoutType.VeryHigh.rawValue + 5
        default:
            return TimeoutType.Medium.rawValue + 1
        }
    }

    var IsTimeOut: Bool {
        if IsCompleted { return false }

        let now = Date()
        let elapsedSeconds = Int(now.timeIntervalSince1970 - startedAt.timeIntervalSince1970)

        return elapsedSeconds > TimeOut
    }

    // MARK: - Run Request

    func RunRequest() async {
        do {
            IsRunning = true
            startedAt = Date()

            if let action = RequestAction {
                result = try await action()
            }

            // Only complete if not already error/completed
            CompletionSource.setResult(result ?? "")

            IsCompleted = true
            IsRunning = false
        }
        catch {
            ForceToComplete(error, logString: "Id:\(Id) Failed to invoke RequestAction()")
        }

        RemoveFromParent()
    }

    // MARK: - Force Complete with Error

    func ForceToComplete(_ error: Error, logString: String) {
        if IsCompleted {
            logger?.LogWarning("No need to force complete the request \(Id) because it is already completed")
            return
        }

        IsRunning = false
        IsCompleted = true

        CompletionSource.setError(error)

        logger?.LogError(error, logString)
    }

    // MARK: - Remove From Parent

    func RemoveFromParent() {
        if let parent = parentList {
            if parent.Contains(self) {
                parent.Remove(self)
                parent.OnItemCompleted(self)
            }
        }
        parentList = nil
    }
}
