import Foundation
import Resolver

@objcMembers
class LoginPageViewModel: AppPageViewModel {
    @LazyInjected var preferenceServices: IPreferences
    static let LogoutRequest = "LogoutRequest"
    static let IsLoggedIn = "IsLoggedIn"

    var SubmitCommand: AsyncCommand!
    var Login: String = ""
    var Password: String = ""

    override init(_ injectedService: PageInjectedServices) {
        
        super.init(injectedService)
        self.SubmitCommand = AsyncCommand(OnSubmitCommand)
    }

    override func Initialize(_ parameters: INavigationParameters) {
        LogMethodStart(#function)
        super.Initialize(parameters)

        if parameters.ContainsKey(LoginPageViewModel.LogoutRequest) {
            preferenceServices.Set(LoginPageViewModel.IsLoggedIn, false)
        }
    }

    func OnSubmitCommand(_ arg: Any?) async {
        LogMethodStart(#function)
        preferenceServices.Set(LoginPageViewModel.IsLoggedIn, true)
        await Services.NavigationService.Navigate("/MoviesPageViewModel")
    }
}
