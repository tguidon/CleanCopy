//
//  PasteboardManager.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/19/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa

protocol PasteboardManagerDelegate {
    func didDetectCleanedURL(urlString: String)
}

class PasteboardManager {

    internal let pasteboard: NSPasteboard!

    internal var timer: Timer?

    internal var lastItemInPasteboard: String? = nil

    public var delegate: PasteboardManagerDelegate?

    init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    func checkPasteboardForTrackingInfo() {
        guard
            let item = pasteboard.pasteboardItems?.first?.string(forType: .string),
            item != lastItemInPasteboard,
            let url = URL(string: item),
            url.scheme != nil,
            url.host != nil
        else {
            return
        }

        clean(url: url)
    }

    func clean(url: URL) {
        // make new components
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path


        if let cleanUrl = components.url {
            // cache item
            self.lastItemInPasteboard = cleanUrl.absoluteString
            // set pasteboard
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(cleanUrl.absoluteString, forType: .string)

            delegate?.didDetectCleanedURL(urlString: cleanUrl.absoluteString)
        }
    }

    func fire() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.checkPasteboardForTrackingInfo()
        }

        timer?.fire()
    }

    func copyLastCleanedURL() {
        if let item = self.lastItemInPasteboard {
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(item, forType: .string)
        }
    }

}
