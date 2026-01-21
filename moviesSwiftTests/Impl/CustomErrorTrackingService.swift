@testable import moviesSwift

import Foundation

class CustomErrorTrackingService : IErrorTrackingService
{
    let OnError = Event<String>()
    
    func TrackError(_ ex: Error, data: [String: String]?)
    {
        print("TrackError()")
        print("Skip tracking error: \(ex)")
    }
}
