import Foundation
import Resolver

class AddEditMoviePageViewModel: AppPageViewModel {
    static let NEW_ITEM: String = "newItem"
    static let UPDATE_ITEM: String = "updateItem"
    static let REMOVE_ITEM: String = "removeItem"
    static let PhotoChangedEvent: String = "PhotoChanged"
    static let SELECTED_ITEM: String = "selectedItem"

    @LazyInjected var movieService: IMovieService
    @LazyInjected var mediaPickerService: IMediaPickerService

    var SaveCommand: AsyncCommand!
    var ChangePhotoCommand: AsyncCommand!
    var DeleteCommand: AsyncCommand!
    var Model: MovieItemViewModel?
    var IsEdit: Bool = false
    var PhotoChanged: UUID = UUID()

    override init(_ injectedService: PageInjectedServices) {
        
        super.init(injectedService)
        
        self.SaveCommand = AsyncCommand(OnSaveCommand)
        self.ChangePhotoCommand = AsyncCommand(OnChangePhotoCommand)
        self.DeleteCommand = AsyncCommand(OnDeleteCommand)
    }

    override func Initialize(_ parameters: INavigationParameters) {
        LogMethodStart("Initialize")
        super.Initialize(parameters)

        if parameters.ContainsKey(AddEditMoviePageViewModel.NEW_ITEM) {
            self.IsEdit = true
            self.Model = parameters.GetValue(AddEditMoviePageViewModel.SELECTED_ITEM)
            self.Title = "Edit"
        } else {
            self.Model = MovieItemViewModel()
            self.Title = "Add new"
        }
    }

    func OnChangePhotoCommand(_ arg: Any?) async {
        LogMethodStart("OnChangePhotoCommand")
        let deleteText = (!(self.Model?.PosterUrl?.isEmpty ?? true)) ? "Delete" : nil

        let buttons = ["Pick Photo", "Take Photo"]
        let actionResult = await Services.AlertDialogService.DisplayActionSheet(title: "Set photo from", cancel: "Cancel", destruction: deleteText, buttons: buttons)

        if actionResult == buttons[0] {
            if let photo = await mediaPickerService.GetPhotoAsync(options: MediaOptions())
            {
                self.Model?.PosterUrl = photo.FilePath
            } else {
                Services.LoggingService.LogWarning("AddEditMoviePageViewModel: GetPhotoAsync() returned null")
            }
        } else if actionResult == buttons[1] {
            if let photo = await mediaPickerService.TakePhotoAsync(options: MediaOptions()) {
                self.Model?.PosterUrl = photo.FilePath
            } else {
                Services.LoggingService.LogWarning("AddEditMoviePageViewModel: TakePhotoAsync() returned null")
            }
        } else if actionResult == deleteText {
            self.Model?.PosterUrl = nil
        }
        
        PhotoChanged = UUID()//this will notify the UI that the photo has changed
    }

    func OnSaveCommand(_ arg: Any?) async {
        LogMethodStart("OnSaveCommand")

        if (self.Model?.Name.isEmpty ?? true) {
            Services.SnackBarService.ShowError("The Name field is required")
            return
        } else if (self.Model?.Overview.isEmpty ?? true) {
            Services.SnackBarService.ShowError("The Overview field is required")
            return
        }

        var result: Some<MovieDto>? = nil
        if self.IsEdit {
            let dtoModel = self.Model!.ToDto()
            result =  await movieService.UpdateAsync(dtoModel)
        } else {
            result = await movieService.AddAsync(name: self.Model!.Name, overview: self.Model!.Overview, posterUrl: self.Model!.PosterUrl)
        }

        if result?.Success == true {
            let item = MovieItemViewModel(result!.ValueOrThrow)
            let key = self.IsEdit ? AddEditMoviePageViewModel.UPDATE_ITEM : AddEditMoviePageViewModel.NEW_ITEM
            await NavigateBack(NavigationParameters())
            // TODO: NavigationParameters builder usage: add key/item
        } else {
            Services.SnackBarService.ShowError(CommonStrings.GeneralError)
        }
    }

    func OnDeleteCommand(_ arg: Any?) async {
        LogMethodStart("OnDeleteCommand")
        let res = await Services.AlertDialogService.ConfirmAlert(title: "Confirm", message: "Are you sure you want to delete this item?", buttons: ["Yes", "No"])

        if res == true {
            let dtoModel = self.Model!.ToDto()
            let result = await movieService.RemoveAsync(dtoModel)

            if result.Success {
                await NavigateToRoot(NavigationParameters())
                // TODO: add REMOVE_ITEM param
            } else {
                Services.SnackBarService.ShowError(CommonStrings.GeneralError)
            }
        }
    }
}
