//
//  RequestQueueList.swift
//  moviesSwift
//
//  Created by xasan on 06/12/25.
//


import Foundation

internal final class RequestQueueList
{

    private let loggingService: ILoggingService
    private var items: [RequestQueueItem] = []

    // === Events ===
    var RequestStarted = Event<RequestQueueItem>()
    var RequestPending = Event<RequestQueueItem>()
    var RequestCompleted = Event<RequestQueueItem>()

    private let MaxBackgroundRequest = 1
    private let MaxHighPriority = 2

    private let queueSemaphore = AsyncSemaphore(value: 1)
    private let timeOutTimer = MyTimer(.seconds(10))

    private let TAG = "RequestQueueList"

    // MARK: - Init

    init(loggingService: ILoggingService, items: [RequestQueueItem] = [])
    {
        self.loggingService = loggingService
        self.items = items

        // Kotlin: timeOutTimer.Elapsed += ::TimeOutTimer_Elapsed
        _ = timeOutTimer.Elapsed.AddListener
        { [weak self] in
            self?.TimeOutTimer_Elapsed()
        }
    }

    // MARK: - Timeout tick handler

    func TimeOutTimer_Elapsed()
    {
        loggingService.Log("\(TAG): Timeout timer tick — checking for timed out requests.")
        CheckTimeOutRequest()
    }

    // MARK: - MutableList add

    @discardableResult
    func add(_ element: RequestQueueItem) -> Bool
    {
        items.append(element)

        Task.detached(priority: .background)
        { [weak self] in
            await self?.TryRunNextRequest()
        }

        ResumeTimer()
        return true
    }

    func Contains(_ element: RequestQueueItem) -> Bool
    {
        return items.contains(where: { $0 === element })
    }

    @discardableResult
    func Remove(_ element: RequestQueueItem) -> Bool
    {
        if let index = items.firstIndex(where: { $0 === element })
        {
            items.remove(at: index)
            return true
        }
        return false
    }

    // MARK: - Resume / Pause / Release

    func Resume()
    {
        ResumeTimer()
    }

    func Pause()
    {
        timeOutTimer.Stop()
    }

    func Release()
    {
        timeOutTimer.Stop()
        items.removeAll()
    }

    // MARK: - TryRunNextRequest (core scheduling logic)

    func TryRunNextRequest() async -> Bool
    {
        var canStart = false

        await queueSemaphore.WaitAsync()
        

        let nextItem = items.filter
        {
            !$0.IsRunning && !$0.IsCompleted
        }
        .min
        {
            $0.priority.rawValue < $1.priority.rawValue
        }

        if let item = nextItem
        {

            let highPriorityRunning = items.filter
            {
                $0.priority == .High && $0.IsRunning
            }
            .count

            canStart = computeCanStart(item: item, highPriorityRunning: highPriorityRunning)

            if canStart
            {
                OnRequestStarted(item)

                Task.detached(priority: .background)
                { [weak item] in
                    await item?.RunRequest()
                }

            }
            else
            {
                OnRequestPending(item)
            }
        }
        
        //release the semaphore after the method finnishes
        defer
        {
            Task
            {
                await queueSemaphore.Release()
            }
        }

        return canStart
    }

    private func computeCanStart(item: RequestQueueItem, highPriorityRunning: Int) -> Bool
    {
        if item.priority == .High && highPriorityRunning < MaxHighPriority
        {
            return true
        }

        if item.priority != .High && highPriorityRunning == 0 && items.filter({ $0.IsRunning }).count < MaxBackgroundRequest
        {
            return true
        }

        return false
    }

    // MARK: - OnItemCompleted

    func OnItemCompleted(_ item: RequestQueueItem)
    {
        OnRequestCompleted(item)

        Task.detached(priority: .background)
        { [weak self] in
            guard let self = self
            else
            {
                return
            }

            for _ in 0..<self.items.count
            {
                let started = await self.TryRunNextRequest()
                if !started
                {
                    break
                }
            }
        }
    }

    // MARK: - Event Raising

    private func OnRequestStarted(_ e: RequestQueueItem)
    {
        loggingService.Log("\(TAG): Request \(e.Id) started. \(GetQueueInfo())")
        RequestStarted.Invoke(e)
    }

    private func OnRequestPending(_ item: RequestQueueItem?)
    {
        loggingService.LogWarning("\(TAG): Request pending — waiting for free slot. \(GetQueueInfo())")
        if let i = item
        {
            RequestPending.Invoke(i)
        }
    }

    private func OnRequestCompleted(_ e: RequestQueueItem)
    {
        loggingService.Log("\(TAG): Request \(e.Id) completed. \(GetQueueInfo())")
        RequestCompleted.Invoke(e)
    }

    // MARK: - Queue Info

    private func GetQueueInfo() -> String
    {
        let total = items.count
        let running = items.filter
        {
            $0.IsRunning
        }
        .count
        let highPriority = items.filter
        {
            $0.priority == .High
        }
        .count

        return "Queue total: \(total), running: \(running), high-priority: \(highPriority)"
    }

    // MARK: - Timeout handling

    private func CheckTimeOutRequest()
    {
        if items.isEmpty
        {
            StopTimer()
            return
        }

        let timedOut = items.filter
        {
            $0.IsTimeOut
        }

        if timedOut.isEmpty
        {
            loggingService.Log("\(TAG): No timeout requests.")
            return
        }

        loggingService.LogWarning("\(TAG): Found \(timedOut.count) timed out items — removing them.")

        for r in timedOut
        {
            r.ForceToComplete(NSError(domain: "TIMEOUT", code: -1), logString: "\(TAG): Request id:\(r.Id) timed out")
            r.RemoveFromParent()
        }

        if items.isEmpty
        {
            loggingService.LogWarning("\(TAG): No items left — stopping timer.")
            StopTimer()
        }
        else
        {
            loggingService.Log("\(TAG): Attempting to run next request.")
            Task.detached
            { [weak self] in
                _ = await self?.TryRunNextRequest()
            }
        }
    }

    // MARK: - Timer control

    func ResumeTimer()
    {
        if !timeOutTimer.IsEnabled
        {
            loggingService.LogWarning("\(TAG): Starting timeout timer.")
            timeOutTimer.Start()
        }
    }

    func StopTimer()
    {
        loggingService.LogWarning("\(TAG): Stopping timeout timer.")
        timeOutTimer.Stop()
    }
}
