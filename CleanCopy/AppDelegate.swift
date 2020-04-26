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
    internal let notificationsPrefPanePath = "/System/Library/PreferencePanes/Notifications.prefPane"

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        addStatusItemMenu()
        setupPasteboardManager()
        setupUserNotificationCenter()

        checkNotificationSettings { success in
            guard !success else { return }
            self.promptToUpdateNotificationSettings()
        }
    }

    // MARK: - Setup

    internal func addStatusItemMenu() {
        if let button = statusItem.button {
            let image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
            image?.isTemplate = true

            button.image = image
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Copy Last Item", action: #selector(copyLastItemInPasteboard), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func copyLastItemInPasteboard() {
        pasteboardManager.copyLastItemInPasteboard()
    }

    internal func setupPasteboardManager() {
        pasteboardManager.delegate = self
        pasteboardManager.clearContents()
        pasteboardManager.startRepeatingTimer()
    }

    internal func setupUserNotificationCenter() {
        notificationCenter.delegate = self
    }

    internal func checkNotificationSettings(completionHandler: @escaping (_ success: Bool) -> ()) {
        notificationCenter.getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization { success in
                    completionHandler(success)
                }
            case .authorized, .provisional:
                completionHandler(true)
            case .denied:
                completionHandler(false)
            @unknown default:
                completionHandler(false)
            }
        }
    }

    internal func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        notificationCenter.requestAuthorization(options: [.alert]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }

            completionHandler(success)
        }
    }

    internal func showConfirmCopyNotification(forUrl url: URL) {
        let request = buildNotificationRequest(forUrl: url)

        notificationCenter.add(request) { error in
            if error != nil {
                dump(error!)
            }
        }
    }

    internal func buildNotificationRequest(forUrl url: URL) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "New URL Cleaned"
        content.subtitle = "Click here to copy"
        content.body = url.absoluteString
        content.userInfo[urlAbsoluteStringKey] = url.absoluteString

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        return UNNotificationRequest(
            identifier: url.absoluteString, content: content, trigger: trigger
        )
    }

    internal func promptToUpdateNotificationSettings() {
        // Open a view with a button to open settings
        print("promptToUpdateNotificationSettings")

        NSWorkspace.shared.open(URL(fileURLWithPath: notificationsPrefPanePath))
    }

}

extension AppDelegate: PasteboardManagerDelegate {

    func didDetectCleanedURL(url: URL) {
        checkNotificationSettings { success in
            guard success else {
                self.promptToUpdateNotificationSettings()
                return
            }

            self.showConfirmCopyNotification(forUrl: url)
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
