import Foundation
import Resolver
import Observation

@Observable
class MovieDetailPageViewModel: AppPageViewModel
{
    static let PhotoChangedEvent: String = "PhotoChanged"

    var EditCommand: AsyncCommand!
    var Model: MovieItemViewModel?
    var ItemUpdated: UUID = UUID()

    override init(_ injectedService: PageInjectedServices)
    {

        super.init(injectedService)
        self.EditCommand = AsyncCommand(OnEditCommand)
    }

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

            ItemUpdated = UUID()
        }
    }

    func OnEditCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg)
        await Navigate(NameOf(AddEditMoviePageViewModel.self), NavigationParameters()
            .With(MoviesPageViewModel.SELECTED_ITEM, Model))
    }


}
