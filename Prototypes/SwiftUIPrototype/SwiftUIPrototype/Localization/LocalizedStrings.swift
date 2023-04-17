//
//  LocalizedStrings.swift
//  EssentialFeediOS
//
//  Created by Ivo on 17/04/23.
//

import Foundation

protocol LocalizedStrings {
    static func localized(_ key: String, _ args: CVarArg..., fallback value: String, _ table: String) -> String
}

extension LocalizedStrings {
    static func localized(_ key: String,
                          _ args: CVarArg...,
                          fallback value: String = .init(),
                          _ table: String = String(describing: Self.self)) -> String {
        let bundle = Bundle(for: FeedLocalized.self)
        let format = bundle.localizedString(forKey: key, value: value, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}
