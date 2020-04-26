//
//  UNNotificationRequest+Extensions.swift
//  CleanCopyTests
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import XCTest
import UserNotifications
@testable import CleanCopy

class UNNotificationRequest_Extensions: XCTestCase {

    func testUNNotificationRequestKeys() {
        XCTAssertEqual(
            UNNotificationRequest.UserInfoKey.cleanedURLAbsoluteString, UNNotificationRequest.UserInfoKey(rawValue: "cleaned_url_absolute_string")
        )
    }

    func testUNNotificationRequestBuildForURL() {
        let url = URL(string: "https://www.apple.com/cleaned")!
        let request = UNNotificationRequest.build(forUrl: url)

        XCTAssertEqual(request.content.title, "New URL Cleaned")
        XCTAssertEqual(request.content.subtitle, "Click here to copy")
        XCTAssertEqual(request.content.body, "https://www.apple.com/cleaned")
        guard let absoluteString = request.content.userInfo[UNNotificationRequest.UserInfoKey.cleanedURLAbsoluteString.rawValue] as? String else {
            XCTFail(); return
        }
        XCTAssertEqual(absoluteString, "https://www.apple.com/cleaned")

        XCTAssertEqual(request.trigger, UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false))

        XCTAssertEqual(request.identifier, "https://www.apple.com/cleaned")
    }

    func testUNNotificationRequestUserInfoValueForKey() {
        let content = UNMutableNotificationContent()
        content.userInfo[UNNotificationRequest.UserInfoKey.cleanedURLAbsoluteString.rawValue] = "url"

        let request = UNNotificationRequest(
            identifier: "url", content: content, trigger: nil
        )

        XCTAssertEqual(
            request.userInfoValue(forKey: .cleanedURLAbsoluteString), "url"
        )
    }

}
