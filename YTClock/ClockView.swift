//
//  ClockView.swift
//  YTClock
//
//  Created by Yutaka Tsutano on 3/19/18.
//  Copyright © 2018 Yutaka Tsutano. All rights reserved.
//

import Cocoa

class ClockView : NSView, CALayerDelegate {
    private var dialLayer = CALayer()
    private var hourHandLayer = CALayer()
    private var minuteHandLayer = CALayer()
    private var secondHandLayer = CALayer()
    private var capNutLayer = CALayer()

    private var center = CGPoint(x: 64, y: 64)
    private var radius = CGFloat(60)

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

        self.repositionClockElements()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }

    private var timerCounter = 0

    @objc private func onTimer() {
        if timerCounter == 0 {
            repositionClockElements()
            timerCounter = 10
        }
        timerCounter -= 1

        if let m = window?.isMiniaturized, m {
            window!.miniwindowImage = nil
            secondHandLayer.isHidden = true
        } else {
            secondHandLayer.isHidden = false
        }
    }

    func draw(_ layer: CALayer, in ctx: CGContext) {
        switch layer {
        case dialLayer:
            for i in 0...60 {
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

    private func repositionClockElements() {
        let secondAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        let now = Date()
        let calendar = NSCalendar.current
        var second = CGFloat(calendar.component(.second, from: now))
        second += CGFloat(calendar.component(.nanosecond, from: now)) * 1e-9
        let secondRadian = -(second / 60.0) * 2 * .pi
        secondAnimation.fromValue = secondRadian
        secondAnimation.toValue = secondRadian - 2 * .pi
        secondAnimation.duration = 60.0
        secondHandLayer.add(secondAnimation, forKey: "rotation")

        let minuteAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        let minute = CGFloat(calendar.component(.minute, from: now)) + second / 60.0
        let minuteRadian = -(minute / 60.0) * 2 * .pi
        minuteAnimation.fromValue = minuteRadian
        minuteAnimation.toValue = minuteRadian - (2 * .pi) / 60
        minuteAnimation.duration = 60.0
        minuteHandLayer.add(minuteAnimation, forKey: "rotation")

        let hour = CGFloat(calendar.component(.hour, from: now)) + minute / 60.0
        let hourRadian = -(hour / 12.0) * 2 * .pi
        hourHandLayer.transform = CATransform3DMakeRotation(hourRadian, 0.0, 0.0, 1.0)
    }
}
