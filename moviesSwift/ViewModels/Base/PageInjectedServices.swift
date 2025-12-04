import Foundation
import Resolver

class PageInjectedServices: InjectedService {
    @LazyInjected var DeviceService: IDeviceInfo
    @LazyInjected var AlertDialogService: IAlertDialogService
}
