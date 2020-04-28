//
//  MenuViewController.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/26/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa
import UserNotifications

class MenuViewController: NSViewController {

    @IBOutlet weak var pleaseEnableTextField: NSTextField!
    @IBOutlet weak var enableButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!

    internal let notificationsPrefPanePath = "/System/Library/PreferencePanes/Notifications.prefPane"

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        enableButton.action = #selector(openNotificationPreferencesPane)
        quitButton.action = #selector(NSApplication.terminate(_:))
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        getNotificationSettings()
    }

    internal func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .notDetermined, .denied:
                self.setContent(text: "Please enable notifications in system notification settings.")
            default:
                self.setContent(text: "Notifications enabled, enjoy 😎", enableButtonIsHidden: true)
            }
        }
    }

    internal func setContent(text: String, enableButtonIsHidden: Bool = false) {
        DispatchQueue.main.async {
            self.pleaseEnableTextField.stringValue = text
            self.enableButton.isHidden = enableButtonIsHidden
        }
    }

    @objc internal func openNotificationPreferencesPane() {
         NSWorkspace.shared.open(URL(fileURLWithPath: notificationsPrefPanePath))
    }
}
