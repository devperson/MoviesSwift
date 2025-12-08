import Foundation

protocol IErrorTrackingService
{
    var OnError: Event<String>
    {
        get
    }
    func TrackError(_ ex: Error, data: [String: String]?)
}
