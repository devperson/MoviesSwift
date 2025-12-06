
import Resolver

class ContainerLocator
{
    static func Resolve<T>() -> T
    {
        Resolver.resolve(T.self)
    }
}
