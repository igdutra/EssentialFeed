//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Ivo on 03/07/23.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
    }
    
    public static func map(_ imageComments: [ImageComment]) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        let comments = imageComments.map { comment in
            ImageCommentViewModel(message: comment.message,
                                  date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()),
                                  username: comment.username)
        }
        
        return ImageCommentsViewModel(comments: comments)
    }
}
