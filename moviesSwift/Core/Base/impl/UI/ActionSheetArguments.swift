import Foundation

struct ActionSheetArguments
{
    let title: String
    let cancel: String?
    let destruction: String?
    let buttons: [String]
}


//func displayActionSheet(_ args: ActionSheetArguments) async -> String? {
//    await withCheckedContinuation { continuation in
//        showActionSheet(
//            title: args.title,
//            cancel: args.cancel,
//            destruction: args.destruction,
//            buttons: args.buttons
//        ) { selected in
//            continuation.resume(returning: selected)
//        }
//    }
//}
