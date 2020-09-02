//
//  NorthLayout.swift
//  NorthLayout
//
//  Created by BAN Jun on 5/9/15.
//  Copyright (c) 2015 banjun. All rights reserved.
//
#if os(iOS)
    import class UIKit.UIView
    typealias View = UIView
    typealias Size = CGSize
    typealias LayoutPriority = UILayoutPriority
    typealias LayoutAxis = NSLayoutConstraint.Axis
    typealias LayoutGuide = UILayoutGuide
    public typealias FormatOptions = NSLayoutConstraint.FormatOptions
    extension View: LayoutPrioritizable {}

    public final class MinView: UIView, MinLayoutable {
        public init() {
            super.init(frame: .zero)
            setup()
        }
        public required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
        public override var intrinsicContentSize : CGSize {return .zero}
    }

#else
    import class AppKit.NSView
    typealias View = NSView
    typealias Size = NSSize
    typealias LayoutPriority = NSLayoutConstraint.Priority
    typealias LayoutAxis = NSLayoutConstraint.Orientation
    typealias LayoutGuide = NSLayoutGuide
    public typealias FormatOptions = NSLayoutConstraint.FormatOptions

    public final class MinView: NSView, MinLayoutable {
        public init() {
            super.init(frame: .zero)
            setup()
        }
        public required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}
        public override var intrinsicContentSize: NSSize {return .zero}
    }
#endif

extension View {
    /// autolayout with enabling autolayout for subviews as side effects
    public func northLayoutFormat(_ metrics: [String: CGFloat], _ views: [String: AnyObject], options: FormatOptions = []) -> (String) -> Void {
        for case let v as View in views.values {
            if !v.isDescendant(of: self) {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
            }
        }
        return { (format: String) in
            // in case NorthLayout parse failure, fall back to standard VFL
            guard let vfl = try? VFL(format: format) else {
                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics as [String : NSNumber]?, views: views))
                return
            }

            // decompose edge bounds to replace and add constraints with decomposed standard VFL
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl.edgeDecomposed(format: format), options: options, metrics: metrics as [String : NSNumber]?, views: views))

            // replace edge bounds into superview or layoutMarginsguide
            switch vfl.orientation {
            case .h:
                if let leftBound = vfl.firstBound, let leftView = views[vfl.firstView.name] {
                    leftBound.1.predicateList.constraints(lhs: leftView.leftAnchor, rhs: leftBound.0.leftAnchor(for: self), metrics: metrics)
                }
                
                if let rightBound = vfl.lastBound, let rightView = views[vfl.lastView.name] {
                    rightBound.0.predicateList.constraints(lhs: rightBound.1.rightAnchor(for: self), rhs: rightView.rightAnchor, metrics: metrics)
                }
            case .v:
                if let topBound = vfl.firstBound, let topView = views[vfl.firstView.name] {
                    topBound.1.predicateList.constraints(lhs: topView.topAnchor, rhs: topBound.0.topAnchor(for: self), metrics: metrics)
                }
                
                if let bottomBound = vfl.lastBound, let bottomView = views[vfl.lastView.name] {
                    bottomBound.0.predicateList.constraints(lhs: bottomBound.1.bottomAnchor(for: self), rhs: bottomView.bottomAnchor, metrics: metrics)
                }
            }
        }
    }
}


#if os(iOS)
    extension UIViewController {
        /// autolayout by replacing vertical edges `|`...`|` to `topLayoutGuide` and `bottomLayoutGuide`
        public func northLayoutFormat(_ metrics: [String: CGFloat], _ views: [String: AnyObject], options: NSLayoutConstraint.FormatOptions = []) -> (String) -> Void {
            guard let view = view else { fatalError() }
            guard view.enclosingScrollView == nil else {
                // fallback to the view.northLayoutFormat because UIScrollView.contentSize is measured by its layout but not by the layout guides of this view controller
                return view.northLayoutFormat(metrics, views, options: options)
            }

            guard #available(iOS 11, *) else {
                // iOS 10 layoutMarginsGuide does not follow to top/bottom layout guides nor safe area layout guides.
                // we use the layout guides to contain views within them, i.e. do not allow to extend to the below of navbars/toolbars.
                // as top/bottom margin of root view of vc is zero, we replace both `||` and `|` to top/bottom layout guides

                var vs = views
                vs["topLayoutGuide"] = topLayoutGuide
                vs["bottomLayoutGuide"] = bottomLayoutGuide

                let autolayout = view.northLayoutFormat(metrics, vs, options: options)

                return { (format: String) in
                    autolayout(!format.hasPrefix("V:") ? format : format
                        .replacingOccurrences(of: "V:||", with: "V:[topLayoutGuide]")
                        .replacingOccurrences(of: "V:|", with: "V:[topLayoutGuide]")
                        .replacingOccurrences(of: "||", with: "[bottomLayoutGuide]")
                        .replacingOccurrences(of: "|", with: "[bottomLayoutGuide]"))
                }
            }

            // in iOS 11 (and later), just use view NorthLayout as view.layoutMarginsGuide follows safe area
            return view.northLayoutFormat(metrics, views, options: options)
        }
    }

    extension View {
        var enclosingScrollView: UIScrollView? {
            guard let s = self as? UIScrollView else { return superview?.enclosingScrollView }
            return s
        }
    }
#endif


protocol LayoutPrioritizable {
    func setContentCompressionResistancePriority(_ priority: LayoutPriority, for axis: LayoutAxis)
    func setContentHuggingPriority(_ priority: LayoutPriority, for axis: LayoutAxis)
}


extension LayoutPriority {
    static var fitInWindow: LayoutPriority = LayoutPriority(500 - 1) // = NSLayoutPriorityWindowSizeStayPut - 1
    static var fittingSize: LayoutPriority = LayoutPriority(50)
}


// common setup for MinView
protocol MinLayoutable: LayoutPrioritizable {
    func setup()
}
extension MinLayoutable {
    func setup() {
        setContentCompressionResistancePriority(.fittingSize, for: .horizontal)
        setContentCompressionResistancePriority(.fittingSize, for: .vertical)
        setContentHuggingPriority(.fitInWindow, for: .horizontal)
        setContentHuggingPriority(.fitInWindow, for: .vertical)
    }
}
