//
//  AppDelegateTests.swift
//  CleanCopyTests
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import XCTest
import UserNotifications
@testable import CleanCopy

class AppDelegateTests: XCTestCase {

    var sut: AppDelegate!

    override func setUp() {
        super.setUp()

        sut = AppDelegate()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testAppDelegateSetupStatusItem() {
        sut.setupStatusItem()

        XCTAssertNotNil(sut.statusItem.button)
        XCTAssertNotNil(sut.statusItem.button?.image)
        XCTAssertNotNil(sut.statusItem.button?.action)
    }

    func testAppDelegateSetupPasteboardManager() {
        sut.setupPasteboardManager()

        XCTAssertNotNil(sut.pasteboardManager.delegate)
        XCTAssertNotNil(sut.pasteboardManager.timer)
    }

    func testAppDelegateSetupUserNotificationCenter() {
        sut.setupUserNotificationCenter()

        XCTAssertNotNil(UNUserNotificationCenter.current().delegate)
    }

    func testAppDelegateShowPopover() {
        sut.showPopover(sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.sut.popover.isShown)
        }
    }

    func testAppDelegateClosePopover() {
        sut.closePopover(sender: nil)

        XCTAssertFalse(sut.popover.isShown)
    }

}
