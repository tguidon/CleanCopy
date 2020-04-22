//
//  AppDelegate.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/19/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    internal let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    internal let pasteboardManager = PasteboardManager()

    internal let notificationCenter = UNUserNotificationCenter.current()

    internal let urlAbsoluteStringKey = "url_absolute_string"

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addStatusItemMenu()
        setupPasteboardManager()

        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: .alert) { (granted, error) in
            if granted {
                print("Granted")
            } else {
                print("Did not grant")
            }
        }
    }

    // MARK: - Setup

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
    func didDetectCleanedURL(url: URL) {
        showConfirmCopyNotification(forUrl: url)
    }

    func showConfirmCopyNotification(forUrl url: URL) {
        let content = UNMutableNotificationContent()
        content.title = "New URL Cleaned"
        content.subtitle = "Click here to copy"
        content.body = url.absoluteString
        content.userInfo[urlAbsoluteStringKey] = url.absoluteString

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(
            identifier: url.absoluteString, content: content, trigger: trigger
        )

        notificationCenter.add(request) { error in
            if error != nil {
                dump(error!)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let urlAbsoluteString = userInfo[urlAbsoluteStringKey] as? String {
            pasteboardManager.copyToPasteboard(item: urlAbsoluteString)
        }

        completionHandler()
    }
}
