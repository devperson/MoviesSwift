//
//  ActionSheetArguments.swift
//  moviesSwift
//
//  Created by xasan on 06/12/25.
//


final class ActionSheetArguments {

    // Kotlin: var Buttons: List<String>
    private(set) var buttons: [String]

    private(set) var cancel: String?
    private(set) var destruction: String?
    private(set) var title: String

    // Kotlin: val Result = CompletableDeferred<String?>
    let result = TaskCompletionSource<String?>()

    init(title: String, cancel: String?, destruction: String?, buttons: [String]?) {

        self.title = title
        self.cancel = cancel
        self.destruction = destruction

        // Kotlin: buttons?.filter { it != null } ?: emptyList()
        self.buttons = buttons?.compactMap { $0 } ?? []
    }

    // Kotlin: fun SetResult(result: String?) { Result.complete(result) }
    func setResult(_ value: String?) {
        result.setResult(value)
    }
}