import XCTest
//import Resolver

@testable import moviesSwift

final class VMAddEditMoviePageViewModelTest: VmDI
{
    func testT2_1TestCreateProduct() async
    {        
        let loggingService:ILoggingService = ContainerLocator.Resolve()
        let createVm:AddEditMoviePageViewModel = ContainerLocator.Resolve()
        let popupAlert: ISnackbarService = ContainerLocator.Resolve()
        createVm.Initialize(NavigationParameters())
        var errorCount = 0
        let popupSubscription = popupAlert.PopupShowed.AddListener({ popupType in
            
            if popupType == SeverityType.Error
            {
                errorCount += 1;
                print("Error count increased to 1 point")
            }
        });
        await createVm.SaveCommand.ExecuteAsync();
        await Task.Delay(milSeconds: 200);
        XCTAssertTrue(errorCount == 1, "failed: name validation");
        
        createVm.Model?.Name = "Test movie1"
        await createVm.SaveCommand.ExecuteAsync();
        await Task.Delay(milSeconds: 200);
        XCTAssertTrue(errorCount == 2, "failed: Overview validation, expected errorCount == 2 but errorCount:\(errorCount)");
        
        createVm.Model?.Overview = "test overview1";
        createVm.Model?.PosterUrl = "";
        await createVm.SaveCommand.ExecuteAsync();
        await Task.Delay(milSeconds: 200);
        XCTAssertTrue(errorCount == 2, "validation error: expected errorCount == 2 but errorCount: \(errorCount)");
        XCTAssertFalse(loggingService.HasError, "There is another error beside validation error, the exception: ${loggingService.LastError?.stackTraceToString()}");
        
        // We don't need to unsubscribe from the listener because the test will be destroyed
        // along with the popupAlert. But it's still good habit to unsubscribe anyway ))
        popupAlert.PopupShowed.RemoveListener(popupSubscription)
    }
}
