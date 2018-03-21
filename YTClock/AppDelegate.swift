//
//  AppDelegate.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/18/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var clockView: ClockView!
    @IBOutlet weak var sweepingHandMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        clockView.isSweepingEnabled = UserDefaults.standard.bool(forKey: "sweeping")
        sweepingHandMenuItem.state = clockView.isSweepingEnabled ? .on : .off
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidChangeOcclusionState(_ notification: Notification) {
        clockView.isSecondHandHidden = !NSApp.occlusionState.contains(.visible)
    }

    @IBAction func changeSweepingMode(_ sender: Any) {
        clockView.isSweepingEnabled = !clockView.isSweepingEnabled
        sweepingHandMenuItem.state = clockView.isSweepingEnabled ? .on : .off
        UserDefaults.standard.set(clockView.isSweepingEnabled, forKey: "sweeping")
    }
}
