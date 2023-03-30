//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ivo on 30/03/23.
//

import Foundation


struct FeedImageViewModel: Identifiable {
    var id: UUID
    let description: String?
    let location: String?
    let imageName: String
}
