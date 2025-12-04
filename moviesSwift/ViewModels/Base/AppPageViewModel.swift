import Foundation

class AppPageViewModel: PageViewModel {
    var RefreshCommand: AsyncCommand!
    var Services: PageInjectedServices

    init(_ injectedService: PageInjectedServices) {
        self.Services = injectedService
        
        super.init(injectedService)
        
        self.RefreshCommand = AsyncCommand(OnRefreshCommand)
    }

    var IsRefreshing: Bool = false

    // Protected-style method; in Swift use internal and async
    func OnRefreshCommand(_ arg: Any?) async {
        LogMethodStart(#function, arg as Any)
    }
    
    func NameOf(_ type: Any.Type) -> String {
        String(describing: type)
    }
}
