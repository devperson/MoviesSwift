import Resolver

class ContainerLocator
{
    static func Resolve<T>() -> T
    {
        Resolver.resolve(T.self)
    }
    
    static func Resolve<T>(name: String) -> T
    {
        Resolver.resolve(name: Resolver.Name(name))
    }
}
