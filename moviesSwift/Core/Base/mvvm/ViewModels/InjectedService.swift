import Foundation
import Resolver

class InjectedService
{
    @LazyInjected var NavigationService: IPageNavigationService
    @LazyInjected var EventAggregator: IMessagesCenter
    @LazyInjected var LoggingService: ILoggingService
    @LazyInjected var SnackBarService: ISnackbarService
    // @LazyInjected var shareService: IShare
}
