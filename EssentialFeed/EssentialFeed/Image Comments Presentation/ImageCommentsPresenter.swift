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
    
    public static func map(_ comments: [ImageComment],
                           currentDate: Date = Date(),
                           calendar: Calendar = .current,
                           locale: Locale = .current
    ) -> ImageCommentsViewModel {
         let formatter = RelativeDateTimeFormatter()
         formatter.calendar = calendar
         formatter.locale = locale
        
        let comments = comments.map { comment in
            ImageCommentViewModel(message: comment.message,
                                  date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                                  username: comment.username)
        }
        
        return ImageCommentsViewModel(comments: comments)
    }
}
