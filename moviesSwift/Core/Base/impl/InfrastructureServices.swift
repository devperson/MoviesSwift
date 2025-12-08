
import Resolver

open class InfrastructureServices : LoggableService, IInfrastructureServices
{
    @LazyInjected
    private var restQueueService: RequestQueueList

    func Start() async throws
    {

    }

    func Pause() async
    {
        restQueueService.Pause();
    }

    func Resume() async
    {
        restQueueService.Resume();
    }

    func Stop() async
    {
        restQueueService.Release();
    }

}
