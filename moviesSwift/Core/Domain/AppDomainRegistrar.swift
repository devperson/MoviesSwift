import Resolver
import Foundation


class AppDomainRegistrar
{
    static func RegisterTypes()
    {
        Resolver.RegisterDomainServices()
    }
}

extension Resolver
{
    static func RegisterDomainServices()
    {
        register { DbInitializer() as ILocalDbInitilizer }.scope(.application)
        register { RepoMovieMapper() as any IRepoMapper<Movie, MovieTb> }.scope(.application)
        register { MovieRepository() as any IRepository<Movie> }.scope(.application)
        register { MovieRestService() as IMovieRestService }.scope(.application)
        register { DomainInfrastructureService() as IInfrastructureServices }.scope(.application)
    }
}
