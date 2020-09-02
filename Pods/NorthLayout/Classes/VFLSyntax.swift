import Foundation
import FootlessParser

// AST for VisualFormatLanguage with an extended format,
// that enables denoting `||` as Bound.layoutMargin used by VFL.edgeDecomposed
// for view layout margins, including Safe Area handling
struct VFL {
    let orientation: Orientation
    let firstBound: (Bound, Connection)?
    let firstView: View
    let views: [(Connection, View)]
    var lastView: View {return views.last?.1 ?? firstView}
    let lastBound: (Connection, Bound)?

    enum Orientation {case h, v}

    struct View {
        let name: String
        let predicateListWithParens: [Predicate]
    }

    enum Bound: String {
        case superview = "|"
        case layoutMargin = "||" // NOTE: custom VFL element introduced in NorthLayout. indicates bound is layoutMarginsGuide, including Safe Area + spacing
    }

    struct Connection {
        let predicateList: PredicateList
    }

    typealias ViewName = String
    typealias MetricName = String

    enum PredicateList {
        case simplePredicate(SimplePredicate)
        case predicateListWithParens([Predicate])
    }

    enum SimplePredicate {
        case metricName(MetricName)
        case positiveNumber(CGFloat)
    }

    enum Relation {case eq, le, ge}

    enum ObjectOfPredicate {
        case constant(Constant)
        case viewName(ViewName)
    }

    enum Constant {
        case metricName(MetricName)
        case number(CGFloat)
    }

    enum Priority {
        case metricName(MetricName)
        case number(CGFloat)
    }

    struct Predicate {
        let relation: Relation?
        let objectOfPredicate: ObjectOfPredicate
        let priority: Priority?
    }
}

private let identifier = {String($0)} <^> oneOrMore(char("_") <|> alphanumeric)
private let possibleNumber: Parser<Character, String> = (extend <^> optional(string("-"), otherwise: "") <*> oneOrMore(char(".") <|> digit))
private let numberParser: Parser<Character, CGFloat> = possibleNumber >>- {Double($0).map {pure(CGFloat($0))} ?? fail(.Mismatch(AnyCollection([]), "CGFloat", "not a number: \($0)"))}

extension VFL.Relation {
    static var parser: Parser<Character, VFL.Relation> {
        return {_ in .eq} <^> string("==")
            <|> {_ in .le} <^> string("<=")
            <|> {_ in .ge} <^> string(">=")
    }
}

extension VFL.Priority {
    static var parser: Parser<Character, VFL.Priority> {
        return {.number($0)} <^> numberParser
            <|> {.metricName($0)} <^> identifier
    }
}

extension VFL.Constant {
    static var parser: Parser<Character, VFL.Constant> {
        return {.number($0)} <^> numberParser
            <|> {.metricName($0)} <^> identifier
    }
}

extension VFL.ObjectOfPredicate {
    static var parser: Parser<Character, VFL.ObjectOfPredicate> {
        return {.constant($0)} <^> VFL.Constant.parser
            <|> {.viewName($0)} <^> identifier
    }
}

extension VFL.Predicate {
    static var parser: Parser<Character, VFL.Predicate> {
        return curry(VFL.Predicate.init)
            <^> optional(VFL.Relation.parser)
            <*> VFL.ObjectOfPredicate.parser
            <*> optional(char("@") *> VFL.Priority.parser)
    }
}

extension VFL {
    init(format: String) throws {
        self = try parse(VFL.parser, format)
    }

    /// ```
    /// <visualFormatString> ::=
    /// (<orientation>:)?
    /// (<superview><connection>)?
    /// <view>(<connection><view>)*
    /// (<connection><superview>)?```
    static var parser: Parser<Character, VFL> {
        let metricName = identifier
        let positiveNumber: Parser<Character, CGFloat> = numberParser >>- {$0 > 0 ? pure($0) : fail(.Mismatch(AnyCollection([]), "positive", "negative: \($0)"))}
        let simplePredicate: Parser<Character, VFL.SimplePredicate> = ({.positiveNumber($0)} <^> positiveNumber) <|> ({.metricName($0)} <^> metricName)
        let predicateListWithParens: Parser<Character, [VFL.Predicate]> = extend
            <^> (char("(") *> ({[$0]} <^> VFL.Predicate.parser))
            <*> zeroOrMore(char(",") *> VFL.Predicate.parser) <* char(")")
        let predicateList: Parser<Character, VFL.PredicateList> = {.simplePredicate($0)} <^> simplePredicate
            <|> {.predicateListWithParens($0)} <^> predicateListWithParens
        let bound: Parser<Character, VFL.Bound> = {_ in VFL.Bound.layoutMargin} <^> string(VFL.Bound.layoutMargin.rawValue)
            <|> {_ in .superview} <^> string(VFL.Bound.superview.rawValue)
        let connection = (VFL.Connection.init) <^> (char("-") *> predicateList <* char("-")
            <|> {_ in VFL.PredicateList.simplePredicate(.positiveNumber(8))} <^> char("-")
            <|> {_ in VFL.PredicateList.simplePredicate(.positiveNumber(0))} <^> string(""))
        let view = curry(VFL.View.init)
            <^> (char("[") *> identifier)
            <*> optional(predicateListWithParens, otherwise: []) <* char("]")
        let views = zeroOrMore({a in {(a, $0)}} <^> connection <*> view)
        let orientation: Parser<Character, VFL.Orientation> = {_ in .v} <^> string("V:")
            <|> {_ in .h} <^> (string("H:") <|> string(""))
        return curry(VFL.init)
            <^> orientation
            <*> optional(tuple <^> bound <*> connection)
            <*> view
            <*> views
            <*> optional(tuple <^> connection <*> bound)
    }
}
