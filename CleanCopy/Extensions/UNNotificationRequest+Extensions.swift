//
//  UNNotificationRequest+Extensions.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Foundation
import UserNotifications

extension UNNotificationRequest {

    enum UserInfoKey: String {
        case cleanedURLAbsoluteString = "cleaned_url_absolute_string"
    }

    static func build(forUrl cleanedUrl: URL) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "New URL Cleaned"
        content.subtitle = "Click here to copy"
        content.body = cleanedUrl.absoluteString
        content.userInfo[self.UserInfoKey.cleanedURLAbsoluteString.rawValue] = cleanedUrl.absoluteString

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        return UNNotificationRequest(
            identifier: cleanedUrl.absoluteString, content: content, trigger: trigger
        )
    }

    func userInfoValue(forKey key: UserInfoKey) -> String? {
        let userInfo = self.content.userInfo

        switch key {
        case .cleanedURLAbsoluteString:
            return userInfo[UNNotificationRequest.UserInfoKey.cleanedURLAbsoluteString.rawValue] as? String
        }
    }

}
