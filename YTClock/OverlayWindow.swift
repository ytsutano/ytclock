//
//  OverlayWindow.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/18/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

class OverlayWindow : NSWindow {
    private let normalOpacity : CGFloat = 1.0
    private let clickableOpacity : CGFloat = 1.0
    private let mouseHoveringOpacity : CGFloat = 0.2

    private var isClickable = false {
        didSet {
            updateWindowState()
        }
    }

    private var isMouseHovering = false {
        didSet {
            updateWindowState()
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
    }

    override func awakeFromNib() {
        // Set the window level and color.
        self.backgroundColor = NSColor.clear
        alphaValue = 0.0
        isOpaque = false
        level = .statusBar

        // Allow mouse enter/exit event to be generated.
        self.contentView?.addTrackingRect(self.contentView!.bounds, owner: self, userData: nil, assumeInside: false)

        // Make the window draggable.
        isMovableByWindowBackground = true

        // Make it unclickable.
        isClickable = false

        // Register keyboard events.
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { (event) in
            self.isClickable = event.modifierFlags.contains(.option)
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event) -> NSEvent? in
            self.isClickable = event.modifierFlags.contains(.option)
            return event
        }
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
}
