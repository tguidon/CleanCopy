//
//  PasteboardManager.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/19/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa

protocol PasteboardManagerDelegate {
    func didDetectCleanedURL(url: URL)
}

class PasteboardManager {

    internal let pasteboard: NSPasteboard!

    /// Timer use to continuously check for new pasteboard data
    internal var timer: Timer?

    /// Last item we saw in the pasteboard
    internal var lastItemInPasteboard: String? = nil

    public var delegate: PasteboardManagerDelegate?

    // MARK: - Init

    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    // MARK: - Public API Methods

    public func clearContents() {
        pasteboard.clearContents()
    }

    public func startRepeatingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.checkPasteboardForURLToClean()
        }

        timer?.fire()
    }

    public func copyToPasteboard(item: String) {
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(item, forType: .string)
    }

    // MARK: - Internal Methods

    internal func checkPasteboardForURLToClean() {
        guard let url = urlInPasteboard else { return }
        guard let cleanURL = cleanURL(fromURL: url) else { return }

        // Send delegate to interact with UI
        delegate?.didDetectCleanedURL(url: cleanURL)
    }

    internal var urlInPasteboard: URL? {
        // Ensure there is an item in the pasteboard and it is not our last item
        guard let item = pasteboard.pasteboardItems?.first?.string(forType: .string), item != lastItemInPasteboard else {
            return nil
        }

        // Cache item
        self.lastItemInPasteboard = item

        // Cast to a URL, and ensure there is a scheme and host
        guard let url = URL(string: item), url.scheme != nil, url.host != nil else {
            return nil
        }

        return url
    }

    internal func cleanURL(fromURL url: URL) -> URL? {
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path

        guard let cleanUrl = components.url else { return nil }

        guard cleanUrl.absoluteString != url.absoluteStringWithNoTrailingSlash else { return nil }

        return cleanUrl
    }

}
