//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    // For EssentialsLegacy
    public var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
