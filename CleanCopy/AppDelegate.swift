//
//  AppDelegate.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/19/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    internal let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    internal let pasteboardManager = PasteboardManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addStatusItemMenu()
        setupPasteboardManager()
    }

    func addStatusItemMenu() {
        if let button = statusItem.button {
            let image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
            image?.isTemplate = true

            button.image = image
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Copy Last URL", action: #selector(copyLastCleanedURL), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func copyLastCleanedURL() {
        pasteboardManager.copyLastCleanedURL()
    }

    func setupPasteboardManager() {
        pasteboardManager.delegate = self
        pasteboardManager.fire()
    }

}

extension AppDelegate: PasteboardManagerDelegate {

    func didDetectCleanedURL(urlString: String) {
        print(urlString)
        animateDetectedState()
    }

    func animateDetectedState() {
        self.statusItem.button?.contentTintColor = NSColor.controlAccentColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.statusItem.button?.contentTintColor = nil
        }
    }
}
