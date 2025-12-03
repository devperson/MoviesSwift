import Foundation

protocol INavigationAware
{
    func OnNavigatedFrom(_ parameters: INavigationParameters)
    func OnNavigatedTo(_ parameters: INavigationParameters)
}
