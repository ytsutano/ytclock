//
//  ClockView.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/19/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

class ClockView: NSView, CALayerDelegate {
    private var dialLayer = CALayer()
    private var hourHandLayer = CALayer()
    private var minuteHandLayer = CALayer()
    private var secondHandLayer = CALayer()
    private var capNutLayer = CALayer()

    private var center = CGPoint(x: 64, y: 64)
    private var radius = CGFloat(60)

    var isSecondHandHidden : Bool {
        get {
            return secondHandLayer.isHidden
        }
        set {
            secondHandLayer.isHidden = newValue
            if newValue {
                secondHandLayer.removeAllAnimations()
            } else {
                repositionClockElements()
            }
        }
    }

    var isSweepingEnabled = false {
        didSet {
            repositionClockElements()
        }
    }

    private func addAndInitializeLayer(_ newLayer: CALayer, withShadow: Bool) {
        newLayer.delegate = self
        newLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        newLayer.frame = layer!.bounds
        newLayer.contentsScale = layer!.contentsScale

        if withShadow {
            newLayer.shadowColor = .black
            newLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            newLayer.shadowOpacity = 1.0
            newLayer.shadowRadius = 1.0
        }

        layer!.addSublayer(newLayer)
        newLayer.display()
    }

    override func awakeFromNib() {
        wantsLayer = true

        addAndInitializeLayer(dialLayer, withShadow: false)
        addAndInitializeLayer(hourHandLayer, withShadow: true)
        addAndInitializeLayer(minuteHandLayer, withShadow: true)
        addAndInitializeLayer(secondHandLayer, withShadow: false)
        addAndInitializeLayer(capNutLayer, withShadow: false)

        repositionClockElements()
        let timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(repositionClockElements), userInfo: nil, repeats: true)
        timer.tolerance = 10.0

        NotificationCenter.default.addObserver(self, selector: #selector(repositionClockElements), name: NSNotification.Name.NSSystemClockDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(repositionClockElements), name: NSNotification.Name.NSSystemTimeZoneDidChange, object: nil)
    }

    override func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
        return true
    }

    func draw(_ layer: CALayer, in ctx: CGContext) {
        switch layer {
        case dialLayer:
            for i in 0..<60 {
                let rx = cos(CGFloat(i) / 30.0 * .pi)
                let ry = sin(CGFloat(i) / 30.0 * .pi)
                let l: CGFloat = (i % 5 == 0) ? 9 : 4
                let p1 = NSPoint(x: center.x + (radius - l) * rx, y: center.x + (radius - l) * ry)
                let p2 = NSPoint(x: center.x + (radius + 0) * rx, y: center.x + (radius + 0) * ry)
                if i % 5 == 0 {
                    ctx.setLineWidth(2.0)
                    ctx.setStrokeColor(gray: 0.7, alpha: 1.0)
                } else {
                    ctx.setLineWidth(1.0)
                    ctx.setStrokeColor(gray: 0.7, alpha: 0.2)
                }
                ctx.move(to: p1)
                ctx.addLine(to: p2)
                ctx.strokePath()
            }
        case hourHandLayer:
            ctx.setLineCap(.round)

            ctx.setFillColor(.white)
            ctx.addEllipse(in: CGRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5))
            ctx.fillPath()

            ctx.setLineWidth(1)
            ctx.setStrokeColor(.white)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y + radius * 0.55 - 0.5))
            ctx.strokePath()

            ctx.setLineWidth(3)
            ctx.setStrokeColor(.white)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y + radius * 0.16))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y + radius * 0.55 - 0.5))
            ctx.strokePath()
        case minuteHandLayer:
            ctx.setFillColor(.white)
            ctx.addEllipse(in: CGRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5))
            ctx.fillPath()

            ctx.setLineCap(.round)
            ctx.setLineWidth(1)
            ctx.setStrokeColor(.white)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y + radius * 0.5))
            ctx.strokePath()

            ctx.setLineWidth(3)
            ctx.setStrokeColor(.white)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y + radius * 0.16))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y + radius - 5))
            ctx.strokePath()
        case secondHandLayer:
            ctx.setFillColor(NSColor.orange.cgColor)
            ctx.addEllipse(in: CGRect(x: center.x - 2, y: center.y - 2, width: 4, height: 4))
            ctx.fillPath()

            ctx.setLineCap(.round)
            ctx.setLineWidth(1.5)
            ctx.setStrokeColor(NSColor.orange.cgColor)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y - radius * 0.15))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y + radius))
            ctx.strokePath()
            ctx.setLineWidth(3.0)
            ctx.move(to: CGPoint(x: center.x + 0, y: center.y - radius * 0.11))
            ctx.addLine(to: CGPoint(x: center.x + 0, y: center.y - radius * 0.20))
            ctx.strokePath()
        case capNutLayer:
            ctx.setFillColor(gray: 0.3, alpha: 1.0)
            ctx.addEllipse(in: CGRect(x: center.x - 1, y: center.y - 1, width: 2, height: 2))
            ctx.fillPath()
        default:
            break
        }
    }

    @objc private func repositionClockElements() {
        let minimumAnimationDuration = 45.0
        let minuteHandUpdateInterval = 5
        let hourHandUpdateInterval = 10

        // Get the current time in two forms.
        let now = Date()
        let mediaTime = CACurrentMediaTime()

        // Get the time components.
        let calendar = NSCalendar.current
        let second = now.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
        let minute = Double(calendar.component(.minute, from: now))
        let hour = Double(calendar.component(.hour, from: now))

        // Animate the second hand.
        if !isSecondHandHidden {
            if isSweepingEnabled {
                let secondAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                secondAnimation.beginTime = mediaTime - second
                secondAnimation.fromValue = 0
                secondAnimation.toValue = -2.0 * .pi
                secondAnimation.duration = 60.0
                secondAnimation.repeatDuration = minimumAnimationDuration + second
                secondHandLayer.add(secondAnimation, forKey: "rotate")
            } else {
                let secondKeyTimes = 0...60
                let secondAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
                secondAnimation.beginTime = mediaTime - second
                secondAnimation.keyTimes = secondKeyTimes.map { NSNumber(value: Double($0) / 60.0) }
                secondAnimation.values = secondKeyTimes.map { Double($0) * (-2.0 * .pi) / 60.0 }
                secondAnimation.duration = 60.0
                secondAnimation.calculationMode = kCAAnimationDiscrete
                secondAnimation.fillMode = kCAFillModeForwards
                secondAnimation.isRemovedOnCompletion = false
                secondAnimation.repeatDuration = minimumAnimationDuration + second
                secondHandLayer.add(secondAnimation, forKey: "rotate")
            }
        }

        // Animate the minute hand.
        let minuteRadian = -(minute / 60.0) * 2 * .pi
        let minuteNumberOfUpdates = Int(((minimumAnimationDuration + second) / Double(minuteHandUpdateInterval)).rounded(.up))
        let minuteTotalDuration = minuteHandUpdateInterval * minuteNumberOfUpdates
        let minuteKeyTimes = stride(from: 0, through: minuteTotalDuration, by: minuteHandUpdateInterval)
        let minuteAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        minuteAnimation.beginTime = mediaTime - second
        minuteAnimation.keyTimes = minuteKeyTimes.map { NSNumber(value: Double($0) / Double(minuteTotalDuration)) }
        minuteAnimation.values = minuteKeyTimes.map { minuteRadian + Double($0) * (-2.0 * .pi) / (60.0 * 60.0) }
        minuteAnimation.duration = Double(minuteTotalDuration)
        minuteAnimation.calculationMode = kCAAnimationDiscrete
        minuteAnimation.fillMode = kCAFillModeForwards
        minuteAnimation.isRemovedOnCompletion = false
        minuteHandLayer.add(minuteAnimation, forKey: "rotate")

        // Animate the hour hand.
        let hourRadian = -((hour + minute / 60.0) / 12.0) * 2 * .pi
        let hourNumberOfUpdates = Int(((minimumAnimationDuration + second) / Double(hourHandUpdateInterval)).rounded(.up))
        let hourTotalDuration = hourHandUpdateInterval * hourNumberOfUpdates
        let hourKeyTimes = stride(from: 0, through: hourTotalDuration, by: hourHandUpdateInterval)
        let hourAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        hourAnimation.beginTime = mediaTime - second
        hourAnimation.keyTimes = hourKeyTimes.map { NSNumber(value: Double($0) / Double(hourTotalDuration)) }
        hourAnimation.values = hourKeyTimes.map { hourRadian + Double($0) * (-2.0 * .pi) / (60.0 * 60.0 * 24.0) }
        hourAnimation.duration = Double(hourTotalDuration)
        hourAnimation.calculationMode = kCAAnimationDiscrete
        hourAnimation.fillMode = kCAFillModeForwards
        hourAnimation.isRemovedOnCompletion = false
        hourHandLayer.add(hourAnimation, forKey: "rotate")
    }
}
