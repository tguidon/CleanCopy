//
//  EventMonitor.swift
//  CleanCopy
//
//  Created by Taylor Guidon on 4/27/20.
//  Copyright © 2020 Taylor Guidon. All rights reserved.
//

import Cocoa

class EventMonitor {
    internal var monitor: Any?
    internal let mask: NSEvent.EventTypeMask
    internal let handler: (NSEvent?) -> Void

    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
