import Foundation

class AppPageViewModel: PageViewModel
{
    init(_ injectedService: PageInjectedServices)
    {
        self.Services = injectedService

        super.init(injectedService)

        self.RefreshCommand = AsyncCommand(OnRefreshCommand)
    }

    @Published var IsRefreshing: Bool = false
    //Internal properties
    var Services: PageInjectedServices
    //Commands
    var RefreshCommand: AsyncCommand!

    // Protected-style method; in Swift use internal and async
    func OnRefreshCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg as Any)
    }


}
