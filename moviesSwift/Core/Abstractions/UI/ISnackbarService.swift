//
//  ISnackbarService.swift
//  moviesSwift
//
//  Created by xasan on 03/12/25.
//


import Foundation

protocol ISnackbarService
{
    var PopupShowed: Event<SeverityType> { get }
    func ShowError( _ message: String);
    func ShowInfo(_ message: String);
    func Show(message: String, severityType: SeverityType, duration: Int);
}

enum SeverityType
{
    case Info
    case Success
    case Warning
    case Error
}
