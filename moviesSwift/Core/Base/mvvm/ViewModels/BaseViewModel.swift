import Foundation

class BaseViewModel: LoggableViewModel, IDestructible, IInitialize
{
    var Initialized = BaseEvent()
    var OnDestroyed = BaseEvent()

    func Initialize(_ parameters: INavigationParameters)
    {
        Initialized.Invoke()
    }

    func Destroy()
    {
        OnDestroyed.Invoke()
    }
}
