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
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
        }

        addMenu()

        pasteboardManager.fire()
    }

    func addMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Copy Last URL", action: #selector(copyLastCleanedURL), keyEquivalent: "p"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func copyLastCleanedURL() {
        pasteboardManager.copyLastCleanedURL()
    }

}

