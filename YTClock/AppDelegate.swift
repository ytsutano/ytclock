//
//  AppDelegate.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/18/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var clockView: ClockView!

    var miniwindowTimer: Timer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func windowDidMiniaturize(_ notification: Notification) {
        clockView.isSecondHandHidden = true

        updateMiniwindow()
        miniwindowTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateMiniwindow), userInfo: nil, repeats: true)
        miniwindowTimer?.tolerance = 3.0
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        clockView.isSecondHandHidden = false

        miniwindowTimer?.invalidate()
    }

    @objc func updateMiniwindow() {
        // Update the clock image in the Dock.
        window.miniwindowImage = nil
    }
}
