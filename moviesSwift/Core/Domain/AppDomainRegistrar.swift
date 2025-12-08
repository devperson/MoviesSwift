import Resolver
import Foundation


class AppDomainRegistrar
{
    static func RegisterTypes()
    {
        Resolver.RegisterDomainInfrastructureService()
    }
}

extension Resolver
{
    static func RegisterDomainInfrastructureService()
    {
        register { DbInitializer() as ILocalDbInitilizer }.scope(.application)
        register { RepoMovieMapper() as any IRepoMapper<Movie, MovieTb> }.scope(.application)
        register { MovieRepository() as any IRepository<Movie> }.scope(.application)
        register { MovieRestService() as IMovieRestService }.scope(.application)
        register { MyInfrastructureService() as IInfrastructureServices }.scope(.application)
    }
}
