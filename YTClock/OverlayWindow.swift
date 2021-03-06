//
//  OverlayWindow.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/18/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

class OverlayWindow: NSWindow, NSWindowDelegate {
    @IBOutlet weak var clockView: ClockView!
    @IBOutlet weak var backgroundView: NSVisualEffectView!

    private let normalOpacity: CGFloat = 1.0
    private let clickableOpacity: CGFloat = 1.0
    private let mouseHoveringOpacity: CGFloat = 0.2

    private var miniwindowUpdateTimer: Timer?

    private var isClickable = true {
        didSet {
            if isClickable != oldValue {
                updateWindowState()
            }
        }
    }

    private var isMouseHovering = false {
        didSet {
            if isMouseHovering != oldValue {
                updateWindowState()
            }
        }
    }

    private func updateWindowState() {
        ignoresMouseEvents = !isClickable
        NSAnimationContext.current.duration = 0.3

        if isClickable {
            animator().alphaValue = clickableOpacity
        } else {
            animator().alphaValue = isMouseHovering ? mouseHoveringOpacity : normalOpacity
        }

        if isClickable && isMouseHovering {
            backgroundView.isHidden = false
            hasShadow = true
            styleMask.formUnion(.titled)
        } else {
            backgroundView.isHidden = true
            hasShadow = false
            styleMask.subtract(.titled)
        }
    }

    override func awakeFromNib() {
        // Set the window level and color.
        backgroundColor = NSColor.clear
        alphaValue = 0.0
        isOpaque = false
        level = .statusBar

        // Allow mouse enter/exit event to be generated.
        let trackingArea = NSTrackingArea(rect: contentView!.bounds, options: [.mouseEnteredAndExited, .activeAlways, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        contentView?.addTrackingArea(trackingArea)

        // Make the window draggable.
        isMovableByWindowBackground = true

        // Make it unclickable.
        isClickable = false

        // Register keyboard events.
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { (event) in
            self.keyboardFlagsChanged(with: event)
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event) -> NSEvent? in
            self.keyboardFlagsChanged(with: event)
            return event
        }

        delegate = self
    }

    private func keyboardFlagsChanged(with event: NSEvent) {
        isClickable = event.modifierFlags.contains(.option)
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount > 1 {
            // Double click to minimize.
            miniaturize(self)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isMouseHovering = true
    }

    override func mouseExited(with event: NSEvent) {
        isMouseHovering = false
    }

    func windowDidMiniaturize(_ notification: Notification) {
        isClickable = false
        isMouseHovering = false

        DispatchQueue.main.async {
            self.updateMiniwindow()
        }
        miniwindowUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateMiniwindow), userInfo: nil, repeats: true)
        miniwindowUpdateTimer?.tolerance = 3.0
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        miniwindowUpdateTimer?.invalidate()
    }

    @objc private func updateMiniwindow() {
        // Update the clock image in the Dock.
        miniwindowImage = nil
    }
}
