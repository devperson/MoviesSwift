import Mockable
@testable import moviesSwift

@Mockable
protocol InfrastructureServicesGen : IInfrastructureServices
{
    func Start() async throws
    func Pause() async
    func Resume() async
    func Stop() async
}
