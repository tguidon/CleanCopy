//
//  URL+Extensions.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Foundation

extension URL {

    var absoluteStringWithNoTrailingSlash: String {
        var value = self.absoluteString
        if value.last == "/" {
            value = String(value.dropLast())
        }

        return value
    }
}
