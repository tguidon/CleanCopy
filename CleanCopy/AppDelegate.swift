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

    internal let popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = MenuViewController()
        popover.contentSize = NSSize(width: 300, height: 140)
        return popover
    }()

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupPasteboardManager()
        setupUserNotificationCenter()

        checkNotificationSettings { success in
            if !success {
                self.presentPopoverMenuViewController()
            }
        }
    }

    // MARK: - Setup

    internal func setupStatusItem() {
        if let button = statusItem.button {
            let image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
            image?.isTemplate = true
            button.image = image

            button.action = #selector(togglePopover(_:))
        }
    }

    internal func setupPasteboardManager() {
        pasteboardManager.delegate = self

        pasteboardManager.startRepeatingTimer()
    }

    internal func setupUserNotificationCenter() {
        notificationCenter.delegate = self
    }

    // MARK: - Popover

    @objc internal func togglePopover(_ sender: Any?) {
        popover.isShown ? closePopover(sender: sender) : showPopover(sender: sender)
    }

    internal func showPopover(sender: Any?) {
        guard let button = statusItem.button else { return }

        DispatchQueue.main.async {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    internal func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

    internal func presentPopoverMenuViewController() {
        showPopover(sender: nil)
    }

    // MARK: - UNNotification

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

}

extension AppDelegate: PasteboardManagerDelegate {

    func didDetectCleanedURL(url: URL) {
        checkNotificationSettings { success in
            guard success else {
                self.presentPopoverMenuViewController()
                return
            }

            self.showConfirmCopyNotification(forUrl: url)
        }
    }

    internal func showConfirmCopyNotification(forUrl url: URL) {
        let request = UNNotificationRequest.build(forUrl: url)

        notificationCenter.add(request) { error in
            // Handle or log?
            if let error = error {
                dump(error)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let urlAbsoluteString = response.notification.request.userInfoValue(forKey: .cleanedURLAbsoluteString) {
            pasteboardManager.copyToPasteboard(item: urlAbsoluteString)
        }

        completionHandler()
    }
}
