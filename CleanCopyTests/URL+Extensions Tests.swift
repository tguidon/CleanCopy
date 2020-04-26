//
//  URL+Extensions Tests.swift
//  CleanCopyTests
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import XCTest
@testable import CleanCopy

class URL_Extensions_Tests: XCTestCase {

    func testURLAbsoluteStringWithNoTrailingSlash() {
        let url = URL(string: "https://www.apple.com/path")!
        XCTAssertEqual(url.absoluteStringWithNoTrailingSlash, "https://www.apple.com/path")

        let urlWithTrailingSlash = URL(string: "https://www.apple.com/path/")!
        XCTAssertEqual(urlWithTrailingSlash.absoluteStringWithNoTrailingSlash, "https://www.apple.com/path")
    }

}
