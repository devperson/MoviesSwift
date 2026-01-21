import Resolver

class DomainInfrastructureService : InfrastructureServices
{
    @LazyInjected
    var dbInitilizer : ILocalDbInitilizer

    override func Start() async throws
    {
        LogMethodStart(#function);
        try await super.Start()
        try dbInitilizer.InitDb()
    }

    override func Pause() async
    {
        LogMethodStart(#function);
        await super.Pause()
    }

    override func Resume() async
    {
        LogMethodStart(#function);
        await super.Resume()
    }

    override func Stop() async
    {
        LogMethodStart(#function);
        await super.Stop()
        dbInitilizer.Release()
    }

}
