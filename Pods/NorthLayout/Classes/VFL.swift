import Foundation

extension VFL {
    /// decompose visual format into both side of edge connections and a middle remainder format string
    func edgeDecomposed(format: String) -> String {
        // strip decomposed edge connections
        // we do not generate a format string from parsed VFL, for some reliability
        // instead, use a knowledge that first `[` and last `]` separate edge connections
        let decomposed = format
            .drop {$0 != "["}
            .reversed().drop {$0 != "]"}.reversed()

        switch orientation {
        case .h: return "H:" + decomposed
        case .v: return "V:" + decomposed
        }
    }
}

extension VFL.SimplePredicate {
    func value(_ metrics: [String: CGFloat]) -> CGFloat? {
        switch self {
        case let .metricName(n): return metrics[n]
        case let .positiveNumber(v): return v
        }
    }
}

extension VFL.Constant {
    func value(_ metrics: [String: CGFloat]) -> CGFloat? {
        switch self {
        case let .metricName(n): return metrics[n]
        case let .number(v): return v
        }
    }
}

extension VFL.Priority {
    func value(_ metrics: [String: CGFloat]) -> CGFloat? {
        switch self {
        case let .metricName(n): return metrics[n]
        case let .number(v): return v
        }
    }
}

extension VFL.PredicateList {
    /// returns constraints: `lhs (==|<=|>=) rhs + constant`
    @discardableResult
    func constraints<T>(lhs: NSLayoutAnchor<T>, rhs: NSLayoutAnchor<T>, metrics: [String: CGFloat]) -> [NSLayoutConstraint] {
        let cs: [NSLayoutConstraint]
        switch self {
        case let .simplePredicate(p):
            guard let constant = p.value(metrics) else { return [] }
            cs = [lhs.constraint(equalTo: rhs, constant: constant)]
        case let .predicateListWithParens(predicates):
            cs = predicates.compactMap { p in
                guard case let .constant(c) = p.objectOfPredicate else { return nil } // NOTE: For the objectOfPredicate production, viewName is acceptable only if the subject of the predicate is the width or height of a view
                guard let constant = c.value(metrics) else { return nil }

                let constraint: NSLayoutConstraint
                switch p.relation {
                case .eq?, nil:
                    constraint = lhs.constraint(equalTo: rhs, constant: constant)
                case .le?:
                    constraint = lhs.constraint(lessThanOrEqualTo: rhs, constant: constant)
                case .ge?:
                    constraint = lhs.constraint(greaterThanOrEqualTo: rhs, constant: constant)
                }
                _ = p.priority?.value(metrics).map {constraint.priority = LayoutPriority(rawValue: Float($0))}
                return constraint
            }
        }
        cs.forEach {$0.isActive = true}
        return cs
    }
}

protocol Anchorable {
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension View: Anchorable {}
extension LayoutGuide: Anchorable {}

extension VFL.Bound {
    private func anchorable(for view: View) -> Anchorable {
        switch self {
        case .superview:
            return view
        case .layoutMargin:
            #if os(iOS) || os(tvOS)
                guard #available(iOS 11, tvOS 11, *) else {
                    // in iOS 10, reading layoutMarginsGuide when frame.size is zero and autolayout disabled
                    // has side-effect causing layoutMargins not to work with margins.
                    // workaround: simply enclose by setting false/true
                    let prev = view.translatesAutoresizingMaskIntoConstraints
                    if view.frame.size == .zero {
                        view.translatesAutoresizingMaskIntoConstraints = false
                    }
                    let r = view.layoutMarginsGuide
                    view.translatesAutoresizingMaskIntoConstraints = prev
                    return r
                }
                return view.layoutMarginsGuide
            #else
                // macOS cannot support layout margins. silently fall back to superview.
                return view
            #endif
        }
    }

    func leftAnchor(for view: View) -> NSLayoutXAxisAnchor {
        return anchorable(for: view).leftAnchor
    }

    func rightAnchor(for view: View) -> NSLayoutXAxisAnchor {
        return anchorable(for: view).rightAnchor
    }

    func topAnchor(for view: View) -> NSLayoutYAxisAnchor {
        return anchorable(for: view).topAnchor
    }

    func bottomAnchor(for view: View) -> NSLayoutYAxisAnchor {
        return anchorable(for: view).bottomAnchor
    }
}
