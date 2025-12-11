import Foundation

extension Task where Success == Never, Failure == Never
{
    static func Delay(milSeconds: UInt64) async throws
    {
        try await sleep(nanoseconds: milSeconds * 1_000_000)
    }
}
