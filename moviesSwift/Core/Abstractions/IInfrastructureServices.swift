import Foundation

protocol IInfrastructureServices
{
    func Start() async
    func Pause() async
    func Resume() async
    func Stop() async
}
