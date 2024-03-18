//
//  CommonUI.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/09/01.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit

enum Language {
    case Filipino
    case English
}
public final class CommonUI {
    
    // MARK: Private Properties
    // Overlay and Cutouts
    private static let OverlayName = "SybrinOverlay"
    private static weak var UserView: UIView?
    private static weak var OverlayView: UIView?
    private static var CutoutViews: [UIView] = []

    private static var LabelStartPoint: CGPoint = CGPoint(x: 0, y: 0)
    private static var SubLabelStartPoint: CGPoint = CGPoint(x: 0, y: 0)

    // Borders
    private static let CaptureBorderName = "SybrinCaptureBorder"
    private static let SurroundingBorderName = "SybrinSurroundingBorder"
    private static weak var BorderView: UIView?

    // Label
    private static var Label: UILabel?
    private static var SubLabel: UILabel?
    private static var VerticalLabelsEnabled: Bool = false

    // Fonts
    private static let LabelFontName: String = "Roboto-Regular"
    private static let SubLabelFontName: String = "Roboto-Light"
    private static let LabelFontSize: CGFloat = 20
    private static let SubLabelFontSize: CGFloat = 16
    private static var FontsRegistered = false
    private static var language: Language?

    // Bundle
    private static var FrameworkBundlePath = Bundle.main.path(forResource: "Sybrin_iOS_Common", ofType: "framework", inDirectory: "Frameworks") ?? ""

    // MARK: Public Properties
    public static var labelStartPoint: CGPoint { get { return LabelStartPoint } set { LabelStartPoint = newValue} }
    public static var subLabelStartPoint: CGPoint { get { return SubLabelStartPoint } set { SubLabelStartPoint = newValue} }
    public static weak var delegate: CommonUIDelegate?

    // MARK: Overlay
    public static func addOverlay(to view: UIView) {

        if UserView != nil {
            removeOverlay()
        }
        UserView = view

        guard OverlayView == nil else {
            "Overlay view is not nil".log(.ProtectedError)
            return
        }

        guard let userView = UserView else {
            "User view is nil".log(.ProtectedError)
            return
        }

        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: userView.frame.width , height: userView.frame.height))
        overlayView.tag = CommonUITags.OVERLAY_TAG.rawValue
        if let overlayColour = FrameworkConfiguration.configuration?.overlayColor {
            overlayView.backgroundColor = overlayColour
        }

        if let blurStyle = FrameworkConfiguration.configuration?.overlayBlurStyle, let blurIntensity = FrameworkConfiguration.configuration?.overlayBlurIntensity, blurIntensity > 0 {
            AddOverlayBlur(on: overlayView, with: blurStyle, opacity: blurIntensity, color: FrameworkConfiguration.configuration?.overlayColor)
        }

        userView.addSubview(overlayView)
        userView.setNeedsLayout()
        userView.setNeedsDisplay()

        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer

        OverlayView = overlayView

    }

    public static func removeOverlay() {

        UserView?.removeFromSuperview()
        UserView = nil
        OverlayView?.removeFromSuperview()
        OverlayView = nil
        for cutoutView in CutoutViews {
            cutoutView.removeFromSuperview()
        }
        CutoutViews = []

        LabelStartPoint = CGPoint(x: 0, y: 0)
        SubLabelStartPoint = CGPoint(x: 0, y: 0)

        BorderView?.removeFromSuperview()
        BorderView = nil

        Label?.removeFromSuperview()
        Label = nil

        SubLabel?.removeFromSuperview()
        SubLabel = nil

        delegate = nil

    }
    
    // MARK: Loading
    
    private static var imageView: UIImageView?
    private static var verifyingLabel: UILabel?
    
    public static func loadingAnim(to view: UIView?) {

        var holderView: UIView?

        if view == nil {
            holderView  = CommonUI.OverlayView
        } else {
            holderView = view
        }

        CommonUI.OverlayView?.isHidden = true
        
        self.setupUI(parentView: holderView)

        for cutoutView in CommonUI.CutoutViews {
            cutoutView.removeFromSuperview()
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.loadingIndicator!.isAnimating = false
//        }
    }

    private static func setupUI(parentView: UIView?) {

//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .light
//        }
        
        verifyingLabel = UILabel(frame:CGRect(x: (parentView!.frame.width / 2) - 50, y: (parentView!.frame.height / 2) + 90, width: 80, height: 20));
        
        switch language {
        case .Filipino:
            verifyingLabel?.text = "Bine-verify"
        case .English:
            verifyingLabel?.text = "Verifying"
        default:
            verifyingLabel?.text = "Verifying"
        }
        
        verifyingLabel?.textColor = UIColor.white
        
        imageView  = UIImageView(frame:CGRect(x: (parentView!.bounds.width / 2) + 20, y: (parentView!.bounds.height / 2) + 93, width: 30, height: 20));
        showAnimatingDotsInImageView()
        
        parentView?.addSubview(loadingIndicator!)
        parentView?.bringSubviewToFront(loadingIndicator!)
        parentView?.addSubview(verifyingLabel!)
        parentView?.addSubview(imageView!)

        loadingIndicator!.isAnimating = true
        
        NSLayoutConstraint.activate([
            loadingIndicator!.centerXAnchor
                .constraint(equalTo: parentView!.centerXAnchor),
            loadingIndicator!.centerYAnchor
                .constraint(equalTo: parentView!.centerYAnchor),
            loadingIndicator!.widthAnchor
                .constraint(equalToConstant: 150),
            loadingIndicator!.heightAnchor
                .constraint(equalTo: self.loadingIndicator!.widthAnchor)
        ])
    }
    
    public static func loadingAnimStop(){
        loadingIndicator!.isAnimating = false
    }


    // MARK: - Properties
    private static var loadingIndicator: ProgressView? = {
        let progress = ProgressView(colors: [.red, .systemGreen, .systemBlue], lineWidth: 5)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private static func showAnimatingDotsInImageView() {
            
            let lay = CAReplicatorLayer()
            lay.frame = CGRect(x: 0, y: 8, width: 15, height: 7) //yPos == 12
            let circle = CALayer()
            circle.frame = CGRect(x: 0, y: 0, width: 7, height: 7)
            circle.cornerRadius = circle.frame.width / 2
            circle.backgroundColor = UIColor.white.cgColor //UIColor(red: 110/255.0, green: 110/255.0, blue: 110/255.0, alpha: 1).cgColor//lightGray.cgColor //UIColor.black.cgColor
            lay.addSublayer(circle)
            lay.instanceCount = 3
            lay.instanceTransform = CATransform3DMakeTranslation(10, 0, 0)
            let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            anim.fromValue = 1.0
            anim.toValue = 0.2
            anim.duration = 1
            anim.repeatCount = .infinity
            circle.add(anim, forKey: nil)
            lay.instanceDelay = anim.duration / Double(lay.instanceCount)
            
            imageView!.layer.addSublayer(lay)
        }
    

    // MARK: Blur
    private static func AddOverlayBlur(on view: UIView, with style: UIBlurEffect.Style, opacity: CGFloat, color: UIColor? = nil) {

        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = opacity
            if let color = color, color.cgColor.alpha > 0 {
                blurEffectView.backgroundColor = color
            }

            view.addSubview(blurEffectView)
        } else {
            view.backgroundColor = .black
        }

    }

    // MARK: Cutouts
    public static func addRectCutouts(addBorder: Bool = false, withRoundedCorners: (width: CGFloat, height: CGFloat)? = nil, _ cutoutViews: UIView...) {

        guard let overlayView = OverlayView else {
            "Overlay view is nil".log(.ProtectedError)
            return
        }

        let path = CGMutablePath()
        let borderPath = CGMutablePath()

        var cutoutCount = CutoutViews.count
        for view in cutoutViews {
            if (CommonUITags.CUTOUT_START_TAG.rawValue + cutoutCount) <= CommonUITags.CUTOUT_END_TAG.rawValue {
                view.tag = (CommonUITags.CUTOUT_START_TAG.rawValue + cutoutCount)

                let cutoutRect = CGRect(x: view.frame.minX,
                                        y: ((view.frame.minY) ),
                                        width: view.frame.width,
                                        height: view.frame.height)

                if withRoundedCorners != nil {
                    path.addRoundedRect(in: cutoutRect, cornerWidth: withRoundedCorners!.width, cornerHeight: withRoundedCorners!.height)
                    borderPath.addRoundedRect(in: cutoutRect, cornerWidth: withRoundedCorners!.width, cornerHeight: withRoundedCorners!.height)
                } else {
                    path.addRect(cutoutRect)
                    borderPath.addRect(cutoutRect)
                }

                CutoutViews.append(view)

                cutoutCount += 1
            }
        }

        path.addRect(overlayView.bounds)

        if overlayView.layer.mask != nil {

            for existingCutout in CutoutViews {
                if cutoutViews.first(where: { (newCutout) -> Bool in
                    newCutout.tag == existingCutout.tag
                }) == nil {

                    let cutoutRect = CGRect(x: existingCutout.frame.minX,
                                            y: ((existingCutout.frame.minY) ),
                                            width: existingCutout.frame.width,
                                            height: existingCutout.frame.height)

                    if withRoundedCorners != nil {
                        path.addRoundedRect(in: cutoutRect, cornerWidth: withRoundedCorners!.width, cornerHeight: withRoundedCorners!.height)
                        borderPath.addRoundedRect(in: cutoutRect, cornerWidth: withRoundedCorners!.width, cornerHeight: withRoundedCorners!.height)
                    } else {
                        path.addRect(cutoutRect)
                        borderPath.addRect(cutoutRect)
                    }
                }
            }

        } else {
            overlayView.layer.mask = CAShapeLayer()
        }

        if let maskLayer = overlayView.layer.mask as? CAShapeLayer {
            maskLayer.path = path
            maskLayer.fillRule = .evenOdd
            overlayView.layer.mask = maskLayer

            if addBorder, let borderColor = FrameworkConfiguration.configuration?.overlayBorderColor, let borderThickness = FrameworkConfiguration.configuration?.overlayBorderThickness, borderThickness > 0 {
                let borderLayer = CAShapeLayer()
                borderLayer.path = borderPath
                borderLayer.lineWidth = borderThickness
                borderLayer.strokeColor = borderColor.cgColor
                borderLayer.fillColor = UIColor.clear.cgColor
                borderLayer.frame = overlayView.bounds
                borderLayer.name = SurroundingBorderName
                overlayView.layer.addSublayer(borderLayer)
            } else {
                let flashLayer = CAShapeLayer()
                flashLayer.path = borderPath
                flashLayer.lineWidth = 0
                flashLayer.strokeColor = UIColor.clear.cgColor
                flashLayer.fillColor = UIColor.clear.cgColor
                flashLayer.frame = overlayView.bounds
                flashLayer.name = OverlayName
                overlayView.layer.addSublayer(flashLayer)
            }
        }

    }

    public static func addOvalCutouts(addBorder: Bool = false, _ cutoutViews: UIView...) {

        guard let overlayView = OverlayView else {
            "Overlay view is nil".log(.ProtectedError)
            return
        }

        let path = CGMutablePath()
        let borderPath = CGMutablePath()

        var cutoutCount = CutoutViews.count
        for view in cutoutViews {
            if (CommonUITags.CUTOUT_START_TAG.rawValue + cutoutCount) <= CommonUITags.CUTOUT_END_TAG.rawValue {
                let cutoutRect = CGRect(x: view.frame.minX,
                                        y: ((view.frame.minY) ),
                                        width: view.frame.width,
                                        height: view.frame.height)

                path.addEllipse(in: cutoutRect)
                borderPath.addEllipse(in: cutoutRect)

                view.tag = (CommonUITags.CUTOUT_START_TAG.rawValue + cutoutCount)
                CutoutViews.append(view)

                cutoutCount += 1
            }
        }

        path.addRect(overlayView.bounds)

        if overlayView.layer.mask != nil {

            for existingCutout in CutoutViews {
                if cutoutViews.first(where: { (newCutout) -> Bool in
                    newCutout.tag == existingCutout.tag
                }) == nil {

                    let cutoutRect = CGRect(x: existingCutout.frame.minX,
                                            y: ((existingCutout.frame.minY) ),
                                            width: existingCutout.frame.width,
                                            height: existingCutout.frame.height)

                    path.addEllipse(in: cutoutRect)
                    borderPath.addEllipse(in: cutoutRect)
                }
            }

        } else {
            overlayView.layer.mask = CAShapeLayer()
        }

        if let maskLayer = overlayView.layer.mask as? CAShapeLayer {
            maskLayer.frame = overlayView.bounds
            maskLayer.path = path
            maskLayer.shadowOpacity = 0.7
            maskLayer.shadowRadius = 10.0
            maskLayer.fillColor = UIColor.red.cgColor
            maskLayer.fillMode = .backwards
            maskLayer.fillRule = .evenOdd
            maskLayer.borderColor = UIColor.red.cgColor
            maskLayer.shadowColor = UIColor.red.cgColor
            overlayView.layer.mask = maskLayer

            if addBorder, let borderColor = FrameworkConfiguration.configuration?.overlayBorderColor, let borderThickness = FrameworkConfiguration.configuration?.overlayBorderThickness, borderThickness > 0 {
                let borderLayer = CAShapeLayer()
                borderLayer.path = borderPath
                borderLayer.lineWidth = borderThickness
                borderLayer.strokeColor = borderColor.cgColor
                borderLayer.fillColor = UIColor.clear.cgColor
                borderLayer.frame = overlayView.bounds
                borderLayer.name = SurroundingBorderName
                overlayView.layer.addSublayer(borderLayer)
            } else {
                let flashLayer = CAShapeLayer()
                flashLayer.path = borderPath
                flashLayer.lineWidth = 0
                flashLayer.strokeColor = UIColor.clear.cgColor
                flashLayer.fillColor = UIColor.clear.cgColor
                flashLayer.frame = overlayView.bounds
                flashLayer.name = OverlayName
                overlayView.layer.addSublayer(flashLayer)
            }
        }

    }

    // MARK: Corner Borders
    public static func addOutsideCornerBorders(to view: UIView) {

        guard BorderView == nil else {
            "Border view is already added".log(.ProtectedError)
            return
        }

        if let configBorderColor = FrameworkConfiguration.configuration?.overlayBorderColor, let configBorderLength = FrameworkConfiguration.configuration?.overlayBorderLength, let configBorderThickness = FrameworkConfiguration.configuration?.overlayBorderThickness, configBorderLength > 0 && configBorderThickness > 0 {

            guard let overlayView = OverlayView else { return }

            let viewX = view.frame.minX
            let viewY = view.frame.minY
            let viewHeight = view.frame.size.height
            let viewWidth = view.frame.size.width

            // Layer
            let borderColour = configBorderColor.cgColor

            // The length of the drawn borders
            let borderHeight: CGFloat = configBorderLength
            let borderWidth: CGFloat = configBorderLength

            // TOP LEFT
            let topLeft = CALayer()
            topLeft.frame = CGRect(
                x: (viewX - configBorderThickness),
                y: (viewY - configBorderThickness),
                width: (borderWidth),
                height: (borderHeight)
            )
            topLeft.backgroundColor = borderColour
            topLeft.name = CaptureBorderName
            overlayView.layer.addSublayer(topLeft)

            // TOP RIGHT
            let topRight = CALayer()
            topRight.frame = CGRect(
                x: (viewX + viewWidth - borderWidth + configBorderThickness),
                y: (viewY - configBorderThickness),
                width: (borderWidth),
                height: (borderHeight)
            )
            topRight.backgroundColor = borderColour
            topRight.name = CaptureBorderName
            overlayView.layer.addSublayer(topRight)

            // BOTTOM LEFT
            let bottomLeft = CALayer()
            bottomLeft.frame = CGRect(
                x: (viewX - configBorderThickness),
                y: (viewY + viewHeight - borderHeight + configBorderThickness),
                width: (borderWidth),
                height: (borderHeight)
            )
            bottomLeft.backgroundColor = borderColour
            bottomLeft.name = CaptureBorderName
            overlayView.layer.addSublayer(bottomLeft)

            // BOTTOM RIGHT
            let bottomRight = CALayer()
            bottomRight.frame = CGRect(
                x: (viewX + viewWidth - borderWidth + configBorderThickness),
                y: (viewY + viewHeight - borderHeight + configBorderThickness),
                width: (borderWidth),
                height: (borderHeight)
            )
            bottomRight.backgroundColor = borderColour
            bottomRight.name = CaptureBorderName
            overlayView.layer.addSublayer(bottomRight)

            BorderView = view
        }

    }

    public static func addInsideCornerBorders(to view: UIView) {

        guard BorderView == nil else {
            "Border view is already added".log(.ProtectedError)
            return
        }

        if let configBorderColor = FrameworkConfiguration.configuration?.overlayBorderColor, let configBorderLength = FrameworkConfiguration.configuration?.overlayBorderLength, let configBorderThickness = FrameworkConfiguration.configuration?.overlayBorderThickness, configBorderLength > 0 && configBorderThickness > 0 {

            let viewHeight = view.frame.size.height
            let viewWidth = view.frame.size.width

            // Layer
            let borderColour = configBorderColor.cgColor

            // The length of the drawn borders
            let borderHeight: CGFloat = configBorderLength
            let borderWidth: CGFloat = configBorderLength

            // TOP LEFT VERTICAL
            let topLeftVertical = CALayer()
            topLeftVertical.frame = CGRect(
                x: 0,
                y: 0,
                width: configBorderThickness,
                height: borderHeight
            )
            topLeftVertical.backgroundColor = borderColour
            topLeftVertical.name = CaptureBorderName
            view.layer.addSublayer(topLeftVertical)

            // TOP LEFT HORIZONTAL
            let topLeftHorizontal = CALayer()
            topLeftHorizontal.frame = CGRect(
                x: 0,
                y: 0,
                width: borderWidth,
                height: configBorderThickness
            )
            topLeftHorizontal.backgroundColor = borderColour
            topLeftHorizontal.name = CaptureBorderName
            view.layer.addSublayer(topLeftHorizontal)

            // TOP RIGHT VERTICAL
            let topRightVertical = CALayer()
            topRightVertical.frame = CGRect(
                x: (viewWidth - configBorderThickness),
                y: 0,
                width: configBorderThickness,
                height: borderHeight
            )
            topRightVertical.backgroundColor = borderColour
            topRightVertical.name = CaptureBorderName
            view.layer.addSublayer(topRightVertical)

            // TOP RIGHT HORIZONTAL
            let topRightHorizontal = CALayer()
            topRightHorizontal.frame = CGRect(
                x: (viewWidth - borderWidth),
                y: 0,
                width: borderWidth,
                height: configBorderThickness
            )
            topRightHorizontal.backgroundColor = borderColour
            topRightHorizontal.name = CaptureBorderName
            view.layer.addSublayer(topRightHorizontal)

            // BOTTOM LEFT VERTICAL
            let bottomLeftVertical = CALayer()
            bottomLeftVertical.frame = CGRect(
                x: 0,
                y: (viewHeight - borderHeight),
                width: configBorderThickness,
                height: borderHeight
            )
            bottomLeftVertical.backgroundColor = borderColour
            bottomLeftVertical.name = CaptureBorderName
            view.layer.addSublayer(bottomLeftVertical)

            // BOTTOM LEFT HORIZONTAL
            let bottomLeftHorizontal = CALayer()
            bottomLeftHorizontal.frame = CGRect(
                x: 0,
                y: (viewHeight - configBorderThickness),
                width: borderWidth,
                height: configBorderThickness
            )
            bottomLeftHorizontal.backgroundColor = borderColour
            bottomLeftHorizontal.name = CaptureBorderName
            view.layer.addSublayer(bottomLeftHorizontal)

            // BOTTOM RIGHT VERTICAL
            let bottomRightVertical = CALayer()
            bottomRightVertical.frame = CGRect(
                x: (viewWidth - configBorderThickness),
                y: (viewHeight - borderHeight),
                width: configBorderThickness,
                height: borderHeight
            )
            bottomRightVertical.backgroundColor = borderColour
            bottomRightVertical.name = CaptureBorderName
            view.layer.addSublayer(bottomRightVertical)

            // BOTTOM RIGHT HORIZONTAL
            let bottomRightHorizontal = CALayer()
            bottomRightHorizontal.frame = CGRect(
                x: (viewWidth - borderWidth),
                y: (viewHeight - configBorderThickness),
                width: borderWidth,
                height: configBorderThickness
            )
            bottomRightHorizontal.backgroundColor = borderColour
            bottomRightHorizontal.name = CaptureBorderName
            view.layer.addSublayer(bottomRightHorizontal)

            BorderView = view
        }

    }

    // MARK: Flashing UI
    public static func flashBorders(withColor color: UIColor, animationTimeSeconds: Double = 1, repeatCount: Float = 3) {

        if let captureView = BorderView, let sublayers = captureView.layer.sublayers {
            if captureView.layer.name?.lowercased() == CaptureBorderName.lowercased() {
                captureView.layer.add(GetAnimation(for: "backgroundColor", fromValue: captureView.layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
            } else if let layer = captureView.layer as? CAShapeLayer, layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                layer.add(GetAnimation(for: "strokeColor", fromValue: layer.strokeColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "strokeColor")
            }
            for layer in sublayers {
                if layer.name?.lowercased() == CaptureBorderName.lowercased() {
                    layer.add(GetAnimation(for: "backgroundColor", fromValue: layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
                } else if let layer = layer as? CAShapeLayer, layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                    layer.add(GetAnimation(for: "strokeColor", fromValue: layer.strokeColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "strokeColor")
                }
            }
        }

        if let overlayView = OverlayView, let sublayers = overlayView.layer.sublayers {
            if overlayView.layer.name?.lowercased() == CaptureBorderName.lowercased() {
                overlayView.layer.add(GetAnimation(for: "backgroundColor", fromValue: overlayView.layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
            } else if let layer = overlayView.layer as? CAShapeLayer, layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                layer.add(GetAnimation(for: "strokeColor", fromValue: layer.strokeColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "strokeColor")
            }
            for layer in sublayers {
                if layer.name?.lowercased() == CaptureBorderName.lowercased() {
                    layer.add(GetAnimation(for: "backgroundColor", fromValue: layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
                } else if let layer = layer as? CAShapeLayer, layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                    layer.add(GetAnimation(for: "strokeColor", fromValue: layer.strokeColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "strokeColor")
                }
            }
        }

    }

    public static func flashOverlay(withColor color: UIColor, animationTimeSeconds: Double = 1, repeatCount: Float = 3) {

        // The backgroundColor of the surrounding border act as the overlay
        if let captureView = BorderView, let sublayers = captureView.layer.sublayers {
            if captureView.layer.name?.lowercased() == OverlayName.lowercased() || captureView.layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                captureView.layer.add(GetAnimation(for: "backgroundColor", fromValue: captureView.layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
            }
            for layer in sublayers {
                if layer.name?.lowercased() == OverlayName.lowercased() || layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                    layer.add(GetAnimation(for: "backgroundColor", fromValue: layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
                }
            }
        }

        if let overlayView = OverlayView, let sublayers = overlayView.layer.sublayers {
            if overlayView.layer.name?.lowercased() == OverlayName.lowercased() || overlayView.layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                overlayView.layer.add(GetAnimation(for: "backgroundColor", fromValue: overlayView.layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
            }
            for layer in sublayers {
                if layer.name?.lowercased() == OverlayName.lowercased() || layer.name?.lowercased() == SurroundingBorderName.lowercased() {
                    layer.add(GetAnimation(for: "backgroundColor", fromValue: layer.backgroundColor, toValue: color.cgColor, duration: animationTimeSeconds, repeatCount: repeatCount), forKey: "backgroundColor")
                }
            }
        }

    }

    private static func GetAnimation(for keyPath: String, fromValue: Any?, toValue: Any?, duration: Double, repeatCount: Float) -> CABasicAnimation {

        let animationDuration = TimeInterval(exactly: duration)!

        let animation = CABasicAnimation(keyPath: keyPath)
        animation.beginTime = CACurrentMediaTime() + 0.0
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = animationDuration
        animation.repeatCount = repeatCount
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        animation.autoreverses = true

        return animation

    }

    // MARK: Labels
    public static func updateLabelText(view: UIView? = nil, to labelText: String, animationColor: UIColor? = .green, forceAnimation: Bool = false) {

        guard let textColor = FrameworkConfiguration.configuration?.overlayLabelTextColor else { return }
        guard let labelView = Label else {
            AddLabel(to: view, with: labelText, color: textColor)
            return
        }
        guard forceAnimation || labelView.text != labelText else { return }

        if let animationColor = animationColor {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                labelView.textColor = animationColor
                labelView.alpha = 0.0
            }, completion: { res in
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                    labelView.text = labelText
                    labelView.alpha = 1
                    labelView.textColor = textColor
                }, completion: nil)
            })
        } else {
            labelView.text = labelText
            labelView.textColor = textColor
        }

    }

    public static func updateSubLabelText(view: UIView? = nil, to labelText: String, animationColor: UIColor? = .green, forceAnimation: Bool = false) {

        guard let textColor = FrameworkConfiguration.configuration?.overlaySubLabelTextColor else { return }
        guard let labelView = SubLabel else {
            AddSubLabel(to: view, with: labelText, color: textColor)
            return
        }
        guard forceAnimation || labelView.text != labelText else { return }

        if let animationColor = animationColor {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                labelView.textColor = animationColor
                labelView.alpha = 0.0
            }, completion: { res in
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                    labelView.text = labelText
                    labelView.alpha = 1
                    labelView.textColor = textColor
                }, completion: nil)
            })
        } else {
            labelView.text = labelText
            labelView.textColor = textColor
        }

    }

    private static func AddLabel(to view: UIView? = nil, with labelText: String, color: UIColor) {

        var holderView: UIView?
        
        if view == nil {
            holderView  = OverlayView
        } else {
            holderView = view
        }

        if !FontsRegistered {
            RegisterFonts()
        }

        guard FontsRegistered else { return "Failed to register fonts".log(.ProtectedError) }

        let customFont = UIFont(name: LabelFontName, size: LabelFontSize)
        let tWidth: CGFloat = holderView?.frame.width ?? 0
        let tHeight: CGFloat = 40
        let tX: CGFloat = 0
        let tY: CGFloat = LabelStartPoint.y - (tHeight * 1.5)

        let titleFrame: CGRect = CGRect(x: tX, y: tY, width: tWidth , height: tHeight)
        let titleLabel = UILabel(frame: titleFrame)
        titleLabel.text = labelText
        titleLabel.textColor = color
        titleLabel.alpha = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFontMetrics.default.scaledFont(for: customFont ?? titleLabel.font!)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.tag = CommonUITags.LABEL_TAG.rawValue

        Label = titleLabel

        holderView?.addSubview(titleLabel)
        holderView?.bringSubviewToFront(titleLabel)

        UIView.animate(withDuration: TimeInterval(exactly: 0.500)!, delay: 0, options: [.transitionCrossDissolve], animations: {
            titleLabel.alpha = 1
        }, completion: nil)

        if VerticalLabelsEnabled {
            titleLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
            titleLabel.frame.origin.x = holderView?.frame.width ?? 0 - titleLabel.frame.size.width
            titleLabel.frame.origin.y = holderView?.frame.height ?? 0 / 2 - (titleLabel.frame.size.height / 2)

            titleLabel.setNeedsDisplay()
        }

    }

    private static func AddSubLabel(to view: UIView? = nil, with subLabelText: String, color: UIColor) {

        var holderView: UIView?
        
        if view == nil {
            holderView  = OverlayView
        } else {
            holderView = view
        }

        if !FontsRegistered {
            RegisterFonts()
        }

        guard FontsRegistered else { return "Failed to register fonts".log(.ProtectedError) }

        let customFont = UIFont(name: SubLabelFontName, size: SubLabelFontSize)
        let tWidth: CGFloat = holderView?.frame.width ?? 0
        let tHeight: CGFloat = 40
        let tX: CGFloat = 0
        let lY: CGFloat = SubLabelStartPoint.y + (tHeight / 2)

        let subFrame: CGRect = CGRect(x: tX, y: lY, width: tWidth , height: tHeight)
        let subLabel = UILabel(frame: subFrame)
        subLabel.text = subLabelText
        subLabel.textColor = color
        subLabel.alpha = 0
        subLabel.textAlignment = .center
        subLabel.font = UIFontMetrics.default.scaledFont(for: customFont ?? subLabel.font!)
        subLabel.adjustsFontForContentSizeCategory = true
        subLabel.numberOfLines = 0
        subLabel.tag = CommonUITags.SUB_LABEL_TAG.rawValue

        SubLabel = subLabel

        holderView?.addSubview(subLabel)
        holderView?.bringSubviewToFront(subLabel)

        UIView.animate(withDuration: TimeInterval(exactly: 0.500)!, delay: 0, options: [.transitionCrossDissolve], animations: {
            subLabel.alpha = 1
        }, completion: nil)

        if VerticalLabelsEnabled {
            subLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
            subLabel.frame.origin.x = holderView?.frame.width ?? 0 - subLabel.frame.size.width - (subLabel.frame.width + 10)
            subLabel.frame.origin.y = holderView?.frame.height ?? 0 / 2 - (subLabel.frame.size.height )

            subLabel.setNeedsDisplay()
        }

    }

    private static func RegisterFonts() {

        guard !FontsRegistered else { return }
        guard let bundle = Bundle(identifier: "com.sybrin.Sybrin-iOS-Common") else { return }

        UIFont.RegisterFont(withFilenameString: LabelFontName, bundle: bundle)
        UIFont.RegisterFont(withFilenameString: SubLabelFontName, bundle: bundle)

        FontsRegistered = true

    }

    // MARK: Flash Light
    public static func addFlashLightButton(to view: UIView?) {

        var holderView: UIView?
        
        if view == nil {
            holderView  = OverlayView
        } else {
            holderView = view
        }
        
        guard holderView?.viewWithTag(CommonUITags.FLASH_BUTTON_TAG.rawValue) == nil else {
            "Flash light button is already added".log(.ProtectedError)
            return
        }

        let viewWidth = holderView?.frame.width ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height

        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        let buttonMargin: CGFloat = 10

        let buttonX: CGFloat = (viewWidth - buttonWidth) - buttonMargin
        let buttonY: CGFloat = statusBarHeight + buttonMargin

        let button = UIButton(frame: CGRect(x: buttonX , y: buttonY, width: buttonWidth, height: buttonHeight))
        button.tag = CommonUITags.FLASH_BUTTON_TAG.rawValue
        let bundle = Bundle(url: NSURL(fileURLWithPath: FrameworkBundlePath) as URL)
        let flashImage = UIImage(named: "flashOff_w", in: bundle, compatibleWith: nil)
        button.setBackgroundImage(flashImage, for: .normal)

        button.addTarget(self, action: #selector(FlashLightButtonPressed), for: .touchUpInside)

        holderView?.addSubview(button)
        holderView?.bringSubviewToFront(button)

    }

    @objc private static func FlashLightButtonPressed(sender: UIButton!) {

        guard let view = OverlayView else {
            "Overlay view is nil".log(.ProtectedError)
            return
        }

        let flashState = CameraHandler.toggleFlashLight()

        let bundle = Bundle(url: NSURL(fileURLWithPath: FrameworkBundlePath) as URL)
        let flashOnImage = UIImage(named: "flashOn_w", in: bundle, compatibleWith: nil)
        let flashOffImage = UIImage(named: "flashOff_w", in: bundle, compatibleWith: nil)

        let button = view.viewWithTag(CommonUITags.FLASH_BUTTON_TAG.rawValue) as? UIButton

        if flashState {
            button?.setBackgroundImage(flashOnImage, for: .normal)
        } else {
            button?.setBackgroundImage(flashOffImage, for: .normal)
        }

    }

    // MARK: Back Button
    public static func addBackButton(to view: UIView?) {
        
        var holderView: UIView?
        
        if view == nil {
            holderView  = OverlayView
        } else {
            holderView = view
        }
        
        guard holderView?.viewWithTag(CommonUITags.BACK_BUTTON_TAG.rawValue) == nil else {
            "Back button is already added".log(.ProtectedError)
            return
        }

        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height

        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        let buttonMargin: CGFloat = 10

        let buttonX: CGFloat = buttonMargin
        let buttonY: CGFloat = statusBarHeight + buttonMargin

        let button = UIButton(frame: CGRect(x: buttonX , y: buttonY, width: buttonWidth, height: buttonHeight))
        button.tag = CommonUITags.BACK_BUTTON_TAG.rawValue
        let bundle = Bundle(url: NSURL(fileURLWithPath: FrameworkBundlePath) as URL)
        let backImage = UIImage(named: "backArrow", in: bundle, compatibleWith: nil)
        button.setBackgroundImage(backImage, for: .normal)

        button.addTarget(self, action: #selector(BackButtonPressed), for: .touchUpInside)

        holderView?.addSubview(button)
        holderView?.bringSubviewToFront(button)

    }

    @objc private static func BackButtonPressed(sender: UIButton!) {

        delegate?.handleBackButtonPressed()

    }

    // MARK: Scan title 
    public static func addScanTitle(view: UIView?, yMargin: Float = 45) {

        var holderView: UIView?
        
        if view == nil {
            holderView  = OverlayView
        } else {
            holderView = view
        }
        
        let viewWidth = holderView?.frame.width ?? 0

        let labelWidth: CGFloat = 200
        let labelHeight: CGFloat = 30
        let labelMargin: CGFloat = CGFloat(yMargin)

        let labelX: CGFloat = (viewWidth / 2) - labelWidth / 2
        let labelY: CGFloat = (holderView?.center.y ?? 0) - labelMargin

        let label = UILabel(frame: CGRect(x: labelX , y: labelY, width: labelWidth, height: labelHeight))
        label.text = "SCAN DOCUMENT"
        label.font = UIFont(name: "Roboto-black", size: 18.0)
        label.textAlignment = .center

        holderView?.addSubview(label)
        holderView?.bringSubviewToFront(label)

    }
    
}
