import Foundation

protocol IInfrastructureServices
{
    func Start() async throws
    func Pause() async
    func Resume() async
    func Stop() async
}
