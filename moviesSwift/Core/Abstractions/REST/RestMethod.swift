import Foundation

enum RestMethod {
    case GET, POST, PUT, DELETE
}

enum Priority: Int {
    case High = 0
    case Normal = 1
    case Low = 2
    case None = 3
}

enum TimeoutType: Int {
    case Small = 10
    case Medium = 30
    case High = 60
    case VeryHigh = 120
}

enum HttpStatusCode: Int {
    case Unauthorized = 401
    case ServiceUnavailable = 502
}
