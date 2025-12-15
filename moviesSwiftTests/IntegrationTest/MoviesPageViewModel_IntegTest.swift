import Foundation
import XCTest
@testable import moviesSwift


class MoviesPageViewModel_IntegTest : NavigatableTest
{
    
    func testT1_1TestMainPageLoad() async throws
    {
        let pageName = String(describing: MoviesPageViewModel.self)
        await Navigate(name: pageName);
        await Task.Delay(milSeconds: 7000)
        let mainVm:MoviesPageViewModel = try GetNextPage();
        //validate
        XCTAssertTrue(mainVm.MovieItems.count > 0, "No movie items");
        try EnsureNoError();
    }

    
    func testT1_2TestAddMoview() async throws
    {
        let pageName = String(describing: MoviesPageViewModel.self)
        await Navigate(name: pageName);
        await Task.Delay(milSeconds: 1000);
        var mainVm:MoviesPageViewModel = try GetNextPage();
        let oldMovieCount = mainVm.MovieItems.count

        await mainVm.AddCommand.ExecuteAsync();
        //navigated to create page
        let createMovieVm:AddEditMoviePageViewModel = try GetNextPage();
        createMovieVm.Model?.Name = "integration test movie 1";
        createMovieVm.Model?.Overview = "just testing integration test";
        //create movie
        await createMovieVm.SaveCommand.ExecuteAsync();
        try EnsureNoError();
        //navigated back to main page
        mainVm = try GetNextPage();
        let newCount = mainVm.MovieItems.count;
        //validate
        XCTAssertTrue(newCount == oldMovieCount + 1, "The old items count should increase to one item");
        try EnsureNoError();
    }
}
