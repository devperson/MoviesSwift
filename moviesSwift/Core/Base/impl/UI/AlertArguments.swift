//
//  AlertArguments.swift
//  moviesSwift
//
//  Created by xasan on 06/12/25.
//


import Foundation

// Reuse the same TaskCompletionSource<T> from previous example

final class AlertArguments
{

    private(set) var accept: String?
    private(set) var cancel: String?
    private(set) var message: String?
    private(set) var title: String?

    let result: TaskCompletionSource<Bool>

    init(title: String?, message: String?, accept: String?, cancel: String?)
    {
        self.title = title
        self.message = message
        self.accept = accept
        self.cancel = cancel
        self.result = TaskCompletionSource<Bool>()
    }

    func setResult(_ value: Bool)
    {
        result.setResult(value)
    }
}
