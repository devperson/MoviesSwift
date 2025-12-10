import Foundation
import Resolver
import Observation

@Observable
class LoginPageViewModel: AppPageViewModel
{
    @ObservationIgnored @LazyInjected var preferenceServices: IPreferences
    static let LogoutRequest = "LogoutRequest"
    static let IsLoggedIn = "IsLoggedIn"

    var SubmitCommand: AsyncCommand!
    var Login: String = ""
    var Password: String = ""

    override init(_ injectedService: PageInjectedServices)
    {

        super.init(injectedService)
        self.SubmitCommand = AsyncCommand(OnSubmitCommand)
    }

    override func Initialize(_ parameters: INavigationParameters)
    {
        do
        {
            LogMethodStart(#function)
            super.Initialize(parameters)
            
            if parameters.ContainsKey(LoginPageViewModel.LogoutRequest)
            {
                try preferenceServices.Set(LoginPageViewModel.IsLoggedIn, false)
            }
        }
        catch
        {
            Services.LoggingService.TrackError(error)
        }
    }

    func OnSubmitCommand(_ arg: Any?) async
    {
        do
        {
            LogMethodStart(#function)
            try preferenceServices.Set(LoginPageViewModel.IsLoggedIn, true)
            await Navigate("/\(NameOf(MoviesPageViewModel.self))")
        }
        catch
        {
            Services.LoggingService.TrackError(error)
        }
        
        
    }
}
