
import Foundation

struct AlertArguments
{
    let Title: String?
    let Message: String?
    let Accept: String?
    let Cancel: String?
}

//func displayAlert(_ args: AlertArguments) async -> Bool {
//    await withCheckedContinuation { continuation in
//        showAlert(args) { result in
//            continuation.resume(returning: result)
//        }
//    }
//}
