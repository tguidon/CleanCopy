//
//  PasteboardManagerTests.swift
//  CleanCopyTests
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import XCTest
@testable import CleanCopy

class PasteboardManagerTests: XCTestCase {

    var sut: PasteboardManager!

    let pasteboard = NSPasteboard.general

    override func setUp() {
        super.setUp()

        sut = PasteboardManager()
    }

    override func tearDown() {
        sut.timer?.invalidate()
        sut = nil

        super.tearDown()
    }

    func testPasteboardManagerClearContents() {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("hello there", forType: .string)

        XCTAssertNotNil(pasteboard.pasteboardItems)

        sut.clearContents()
        XCTAssertTrue(pasteboard.pasteboardItems!.isEmpty)
    }

    func testPasteboardManagerStartRepeatingTimer() {
        sut.startRepeatingTimer()

        XCTAssertNotNil(sut.timer)
        XCTAssertTrue(sut.timer!.isValid)
    }

    func testPasteboardManagerCopyToPasteboard() {
        sut.copyToPasteboard(item: "copy me")

        let item = pasteboard.pasteboardItems!.first!.string(forType: .string)!
        XCTAssertEqual(item, "copy me")
    }

    func testPasteboardManagerUrlInPasteboard() {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("hello there", forType: .string)
        XCTAssertNil(sut.urlInPasteboard)

        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("https://www.google.com", forType: .string)
        XCTAssertNotNil(sut.urlInPasteboard)
    }

    func testPasteboardManagercleanUrlFromURL() {
        let url = URL(string: "https://www.apple.com")!
        XCTAssertNil(sut.cleanURL(fromURL: url))

        let urlWithQueryParams = URL(string: "https://www.apple.com?tracking=foo")!
        XCTAssertNotNil(sut.cleanURL(fromURL: urlWithQueryParams))
    }

}
