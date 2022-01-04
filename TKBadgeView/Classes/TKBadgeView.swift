import UIKit
import QuartzCore

public enum M13BadgeViewHorizontalAlignment {
    case m13BadgeViewHorizontalAlignmentNone
    case m13BadgeViewHorizontalAlignmentLeft
    case m13BadgeViewHorizontalAlignmentCenter
    case m13BadgeViewHorizontalAlignmentRight
}
public enum M13BadgeViewVerticalAlignment {
    case m13BadgeViewVerticalAlignmentNone
    case m13BadgeViewVerticalAlignmentTop
    case m13BadgeViewVerticalAlignmentMiddle
    case m13BadgeViewVerticalAlignmentBottom
}

public class TKBadgeView: UIView {

    var autoSetCornerRadius = false
    var textLayer: CATextLayer!
    var borderLayer: CAShapeLayer!
    var backgroundLayer: CAShapeLayer!
    var glossMaskLayer: CAShapeLayer!
    var glossLayer: CAGradientLayer!

    //

    // Set the defaults
    public var textColor: UIColor = .white {
        didSet {
            textLayer.foregroundColor = textColor.cgColor
        }
    }
    public var textAlignmentShift: CGSize = .zero
    public var font: UIFont = UIFont.systemFont(ofSize: 16.0) {
        didSet {
            textLayer.fontSize = font.pointSize
            textLayer.font = "SF-UI-Text-Medium" as CFTypeRef
            self.autoSetBadgeFrame()
        }
    }
    public var badgeBackgroundColor: UIColor = .red {
        didSet {
            backgroundLayer.fillColor = self.badgeBackgroundColor.cgColor
        }
    }
    public var showGloss = false {
        didSet {
            if showGloss {
                self.layer.addSublayer(glossLayer)
            } else {
                glossLayer.removeFromSuperlayer()
            }
        }
    }
    public var cornerRadius: CGFloat = 0 {
        didSet {
            autoSetCornerRadius = false
             // Update boackground
             let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
             backgroundLayer?.path = path.cgPath
             glossMaskLayer?.path = path.cgPath
             borderLayer?.path = path.cgPath
        }
    }

    public var horizontalAlignment = M13BadgeViewHorizontalAlignment.m13BadgeViewHorizontalAlignmentRight {
        didSet {
            self.autoSetBadgeFrame()
        }
    }
    public var verticalAlignment = M13BadgeViewVerticalAlignment.m13BadgeViewVerticalAlignmentTop {
        didSet {
            self.autoSetBadgeFrame()
        }
    }
    public var alignmentShift = CGSize(width: 0, height: 0) {
        didSet {
            self.autoSetBadgeFrame()
        }
    }
    public var animateChanges = true {
        didSet {
            if animateChanges {
                // Setup animations
                let frameAnimation = CABasicAnimation()
                frameAnimation.duration = animationDuration

                frameAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
                let actions = ["path": frameAnimation]

                // Animate the path changes
                backgroundLayer.actions = actions
                borderLayer.actions = actions
                glossMaskLayer.actions = actions
            } else {
                backgroundLayer.actions = nil
                borderLayer.actions = nil
                glossMaskLayer.actions = nil
            }
        }
    }
    public var animationDuration = 0.2
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            borderLayer.lineWidth = borderWidth
            self.setNeedsLayout()
        }
    }
    public var borderColor: UIColor = .white {
        didSet {
            borderLayer.strokeColor = borderColor.cgColor
        }
    }
    public var shadowColor: UIColor =  UIColor.init(white: 0.0, alpha: 0.5)
    public var shadowOffset = CGSize(width: 1, height: 1) {
        didSet {

        }
    }
    public var shadowRadius: CGFloat = 1.0 {
        didSet {

        }
    }
    public var shadowText = false {
        didSet {
            if self.shadowText {
                textLayer.shadowColor = self.shadowColor.cgColor
                textLayer.shadowOffset = self.shadowOffset
                textLayer.shadowRadius = self.shadowRadius
                textLayer.shadowOpacity = 1.0
            } else {
                textLayer.shadowColor = nil
                textLayer.shadowOpacity = 0.0
            }
        }
    }
    public var shadowBorder = false {
        didSet {
            if self.shadowBorder {
                borderLayer.shadowColor = self.shadowColor.cgColor
                borderLayer.shadowOffset = self.shadowOffset
                borderLayer.shadowRadius = CGFloat(self.shadowRadius)
                borderLayer.shadowOpacity = 1.0
            } else {
                borderLayer.shadowColor = nil
                borderLayer.shadowOpacity = 0.0
            }
        }
    }
    public var shadowBadge = false {
        didSet {
            if self.shadowBadge {
                backgroundLayer.shadowColor = self.shadowColor.cgColor
                backgroundLayer.shadowOffset = self.shadowOffset
                backgroundLayer.shadowRadius = self.shadowRadius
                backgroundLayer.shadowOpacity = 1.0
            } else {
                backgroundLayer.shadowColor = nil
                backgroundLayer.shadowOpacity = 0.0
            }
        }
    }
    public var hidesWhenZero = true {
        didSet {
            self.hideForZeroIfNeeded()
        }
    }
    public var pixelPerfectText = true
    public var minimumWidth: CGFloat = 0.0 {
        didSet {
            self.autoSetBadgeFrame()
        }
    }
    public var maximumWidth = CGFloat.greatestFiniteMagnitude {
        didSet {
            if maximumWidth < self.frame.size.height {
                maximumWidth = self.frame.size.height
            }
            self.autoSetBadgeFrame()
            self.setNeedsDisplay()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    func setup() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        self.clipsToBounds = false
        cornerRadius = self.frame.size.height / 2
        if self.frame.size.height == 0 {
            var frame = self.frame
            frame.size.height = 24.0
            minimumWidth = 24.0
            self.frame = frame
        } else {
          minimumWidth = self.frame.size.height
        }

        textLayer = CATextLayer()
        textLayer.foregroundColor = textColor.cgColor
        textLayer.font = font.fontName as CFTypeRef
        textLayer.fontSize = font.pointSize
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.truncationMode = CATextLayerTruncationMode.end
        textLayer.isWrapped = false
        textLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        textLayer.contentsScale = UIScreen.main.scale

        // Create the border layer
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        borderLayer.contentsScale = UIScreen.main.scale

        // Create the background layer
        backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = badgeBackgroundColor.cgColor
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backgroundLayer.contentsScale = UIScreen.main.scale

        // Create the gloss layer
        glossLayer = CAGradientLayer()
        glossLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        glossLayer.contentsScale = UIScreen.main.scale
        glossLayer.colors = [
            UIColor(white: 1, alpha: 0.8).cgColor,
            UIColor(white: 1, alpha: 0.25).cgColor,
            UIColor(white: 1, alpha: 0.0).cgColor
        ]
        glossLayer.startPoint = CGPoint(x: 0, y: 0)
        glossLayer.endPoint = CGPoint(x: 0, y: 0.6)
        glossLayer.locations = [0, 0.8, 1]
        glossLayer.type = CAGradientLayerType.axial

        // Create the mask for the gloss layer
        glossMaskLayer = CAShapeLayer()
        glossMaskLayer.fillColor = UIColor.black.cgColor
        glossMaskLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        glossMaskLayer.contentsScale = UIScreen.main.scale
        glossLayer.mask = glossMaskLayer

        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(borderLayer)
        self.layer.addSublayer(textLayer)

        // Setup animations
        let frameAnimation = CABasicAnimation()
        frameAnimation.duration = animationDuration
        frameAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        let actions = ["path": frameAnimation]

        // Animate the path changes
        backgroundLayer.actions = actions
        borderLayer.actions = actions
        glossMaskLayer.actions = actions

        textLayer.font = "SF-UI-Text-Medium" as CFTypeRef
    }

    // MARK: - LAYOUT

    func autoSetBadgeFrame() {

        // Get the width for the current string
        var frame = self.frame
        frame.size.width = sizeForString(text, includeBuffer: true).width
        if frame.size.width < minimumWidth {
            frame.size.width = minimumWidth
        } else if frame.size.width > maximumWidth {
            frame.size.width = maximumWidth
        }

        // Height doesn't need changing

        // Fix horizontal alignment if necessary
        if horizontalAlignment == M13BadgeViewHorizontalAlignment.m13BadgeViewHorizontalAlignmentLeft {
            frame.origin.x = 0 - (frame.size.width / 2) + alignmentShift.width
        } else if horizontalAlignment == M13BadgeViewHorizontalAlignment.m13BadgeViewHorizontalAlignmentCenter {
            frame.origin.x = (self.superview!.bounds.size.width / 2) - (frame.size.width / 2) + alignmentShift.width
        } else if horizontalAlignment == M13BadgeViewHorizontalAlignment.m13BadgeViewHorizontalAlignmentRight {
            guard let superView = self.superview else {
                return
            }
            frame.origin.x = superView.bounds.size.width - (frame.size.width / 2) + alignmentShift.width
        }

        // Fix vertical alignment if necessary
        if verticalAlignment == M13BadgeViewVerticalAlignment.m13BadgeViewVerticalAlignmentTop {
            frame.origin.y = 0 - (frame.size.height / 2) + alignmentShift.height
        } else if verticalAlignment == M13BadgeViewVerticalAlignment.m13BadgeViewVerticalAlignmentMiddle {
            frame.origin.y = (self.superview!.bounds.size.height / 2) - (frame.size.height / 2.0) + alignmentShift.height
        } else if verticalAlignment == M13BadgeViewVerticalAlignment.m13BadgeViewVerticalAlignmentBottom {
            frame.origin.y = self.superview!.bounds.size.height - (frame.size.height / 2.0) + alignmentShift.height
        }

        // Set the corner radius
        if autoSetCornerRadius {
            cornerRadius = self.frame.size.height / 2
        }

        // If we are pixel perfect, constrain to the pixels.
        if pixelPerfectText {
            let roundScale: CGFloat = 1 / UIScreen.main.scale
            frame = CGRect(x: CGFloat(roundf(Float(frame.origin.x / roundScale))) * roundScale,
                           y: CGFloat(roundf(Float(frame.origin.y / roundScale))) * roundScale,
                           width: CGFloat(roundf(Float(frame.size.width / roundScale))) * roundScale,
                           height: CGFloat(roundf(Float(frame.size.height / roundScale))) * roundScale)
        }

        // Change the frame
        self.frame = frame
        let tempFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        backgroundLayer.frame = tempFrame
        var textFrame = CGRect.zero
        if pixelPerfectText {
            let roundScale: CGFloat = 1 / UIScreen.main.scale
            let height = (self.frame.size.height - font.lineHeight) / 2
            let yVal = (roundf(Float((height) / roundScale)) * Float(roundScale)) + Float(self.textAlignmentShift.height)
            textFrame = CGRect(x: self.textAlignmentShift.width,
                               y: CGFloat(yVal),
                               width: self.frame.size.width,
                               height: font.lineHeight)
        } else {
            let height = (self.frame.size.height - font.lineHeight) / 2
            textFrame = CGRect(
                x: self.textAlignmentShift.width,
                y: (height) + self.textAlignmentShift.height,
                width: self.frame.size.width,
                height: font.lineHeight)
        }

        textLayer.frame = textFrame
        glossLayer.frame = tempFrame
        glossMaskLayer.frame = tempFrame
        borderLayer.frame = tempFrame

        // Update the paths of the layers
        let path = UIBezierPath(roundedRect: tempFrame, cornerRadius: cornerRadius)
        backgroundLayer.path = path.cgPath
        borderLayer.path = path.cgPath
        // Inset to not show the gloss over the border
        let insetFrame = self.bounds.insetBy(dx: borderWidth / 2.0, dy: borderWidth / 2.0)
        glossMaskLayer.path = UIBezierPath(roundedRect: insetFrame, cornerRadius: cornerRadius).cgPath

    }

    func sizeForString(_ string: String, includeBuffer include: Bool) -> CGSize {

        // Calculate the width of the text
        var widthPadding: CGFloat = 0.0
        if pixelPerfectText {
            let roundScale = 1 / UIScreen.main.scale
            widthPadding = CGFloat(roundf(Float((font.pointSize * 0.375) / roundScale))) * roundScale
        } else {
            widthPadding = font.pointSize * 0.375
        }

        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: font])

        var textSize = attributedString.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin, context: nil).size

        if include {
            textSize.width += widthPadding * 2
        }
        // Constrain to integers
        if pixelPerfectText {
            let roundScale = 1 / UIScreen.main.scale
            textSize.width = CGFloat(roundf(Float(textSize.width / roundScale))) * roundScale
            textSize.height = CGFloat(roundf(Float(textSize.height / roundScale))) * roundScale
        }

        return textSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Update the frames of the layers
        var textFrame = CGRect.zero
        let height = (self.frame.size.height - font.lineHeight) / 2
        if pixelPerfectText {
            let roundScale = 1 / UIScreen.main.scale
            
            textFrame = CGRect(x: self.textAlignmentShift.width,
                               y: CGFloat((roundf(Float((height) / roundScale)) * Float(roundScale)) + Float(self.textAlignmentShift.height)),
                               width: self.frame.size.width,
                               height: font.lineHeight)
        } else {
            
            textFrame = CGRect(x: self.textAlignmentShift.width,
                               y: (height) + self.textAlignmentShift.height,
                               width: self.frame.size.width,
                               height: font.lineHeight)
        }
        textLayer.frame = textFrame
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        glossLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        glossMaskLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        borderLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)

        // Update the layer's paths
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        backgroundLayer.path = path.cgPath
        borderLayer.path = path.cgPath
        let rectInset = self.bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        glossMaskLayer.path = UIBezierPath(roundedRect: rectInset, cornerRadius: cornerRadius).cgPath
    }

    public var text: String = "" {
        didSet {

            // If the new text is shorter, display the new text before shrinking
            if sizeForString(textLayer!.string as? String ?? "", includeBuffer: true).width >= sizeForString(text, includeBuffer: true).width {
                textLayer.string = text
                setNeedsDisplay()
            } else {
                // If longer display new text after the animation
                if animateChanges {
                    UIView.animate(withDuration: animationDuration) {
                        self.textLayer.string = self.text
                    }
                } else {
                    textLayer.string = text
                }
            }
            // Update the frame
            self.autoSetBadgeFrame()

            // Hide badge if text is zero
            self.hideForZeroIfNeeded()
        }
    }

    private func hideForZeroIfNeeded() {
        self.isHidden = (self.text == "0") && hidesWhenZero
    }

}
