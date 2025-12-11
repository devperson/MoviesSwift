import Foundation
import Resolver
import Observation

class MovieDetailPageViewModel: AppPageViewModel
{
    public static let PhotoChangedEvent: String = "PhotoChanged"
    
    override init(_ injectedService: PageInjectedServices)
    {
        super.init(injectedService)
        self.EditCommand = AsyncCommand(OnEditCommand)
    }
    
    //Internal properties
    var Model: MovieItemViewModel?
    //commands
    var EditCommand: AsyncCommand!
    
    override func Initialize(_ parameters: INavigationParameters)
    {
        LogMethodStart(#function)
        super.Initialize(parameters)

        if parameters.ContainsKey(MoviesPageViewModel.SELECTED_ITEM)
        {
            self.Model = parameters.GetValue(MoviesPageViewModel.SELECTED_ITEM)
        }
    }

    override func OnNavigatedTo(_ parameters: INavigationParameters)
    {
        LogMethodStart(#function)
        super.OnNavigatedTo(parameters)

        if parameters.ContainsKey(AddEditMoviePageViewModel.UPDATE_ITEM)
        {
            self.Model = parameters.GetValue(AddEditMoviePageViewModel.UPDATE_ITEM)

            let updateCellEvent = GetEvent({ MovieCellItemUpdatedEvent() })
            updateCellEvent.Publish(self.Model)

            self.InvalidateView()
        }
    }

    func OnEditCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg)
        await Navigate(NameOf(AddEditMoviePageViewModel.self), NavigationParameters()
            .With(AddEditMoviePageViewModel.SELECTED_ITEM, Model))
    }


}
