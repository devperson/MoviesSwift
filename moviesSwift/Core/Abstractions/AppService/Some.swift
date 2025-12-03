import Foundation

class Some<T> {
    private let value: T?
    public let Exception: Error?

    var Success: Bool {
        return value != nil
    }

    var ValueOrThrow: T {
        guard let v = value else { fatalError("value is null") }
        return v
    }

    init(value: T?, Exception: Error? = nil) {
        self.value = value
        self.Exception = Exception
    }

    static func FromValue(_ value: T?) -> Some<T> {
        return Some(value: value)
    }

    static func FromError(_ ex: Error) -> Some<T> {
        return Some(value: nil, Exception: ex)
    }
}
