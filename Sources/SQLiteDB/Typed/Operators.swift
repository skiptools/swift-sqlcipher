//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

// TODO: use `@warn_unused_result` by the time operator functions support it

private enum Operator: String {
    case plus = "+"
    case minus = "-"
    case or = "OR"
    case and = "AND"
    case not = "NOT "
    case mul = "*"
    case div = "/"
    case mod = "%"
    case bitwiseLeft = "<<"
    case bitwiseRight = ">>"
    case bitwiseAnd = "&"
    case bitwiseOr = "|"
    case bitwiseXor = "~"
    case eq = "="
    case neq = "!="
    case gt = ">"
    case lt = "<"
    case gte = ">="
    case lte = "<="
    case concatenate = "||"

    func infix<T>(_ lhs: Expressible, _ rhs: Expressible, wrap: Bool = true) -> SQLExpression<T> {
        self.rawValue.infix(lhs, rhs, wrap: wrap)
    }

    func wrap<T>(_ expression: Expressible) -> SQLExpression<T> {
        self.rawValue.wrap(expression)
    }
}

public func +(lhs: SQLExpression<String>, rhs: SQLExpression<String>) -> SQLExpression<String> {
    Operator.concatenate.infix(lhs, rhs)
}

public func +(lhs: SQLExpression<String>, rhs: SQLExpression<String?>) -> SQLExpression<String?> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: SQLExpression<String?>, rhs: SQLExpression<String>) -> SQLExpression<String?> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: SQLExpression<String?>, rhs: SQLExpression<String?>) -> SQLExpression<String?> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: SQLExpression<String>, rhs: String) -> SQLExpression<String> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: SQLExpression<String?>, rhs: String) -> SQLExpression<String?> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: String, rhs: SQLExpression<String>) -> SQLExpression<String> {
    Operator.concatenate.infix(lhs, rhs)
}
public func +(lhs: String, rhs: SQLExpression<String?>) -> SQLExpression<String?> {
    Operator.concatenate.infix(lhs, rhs)
}

// MARK: -

public func +<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}
public func +<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.plus.infix(lhs, rhs)
}

public func -<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}
public func -<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.infix(lhs, rhs)
}

public func *<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}
public func *<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.mul.infix(lhs, rhs)
}

public func /<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}
public func /<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.div.infix(lhs, rhs)
}

public prefix func -<V: Value>(rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype: Number {
    Operator.minus.wrap(rhs)
}
public prefix func -<V: Value>(rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype: Number {
    Operator.minus.wrap(rhs)
}

// MARK: -

public func %<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}
public func %<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.mod.infix(lhs, rhs)
}

public func <<<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}
public func <<<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseLeft.infix(lhs, rhs)
}

public func >><V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}
public func >><V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseRight.infix(lhs, rhs)
}

public func &<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}
public func &<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseAnd.infix(lhs, rhs)
}

public func |<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}
public func |<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseOr.infix(lhs, rhs)
}

public func ^<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<V?> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<V> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<V?> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}
public func ^<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    (~(lhs & rhs)) & (lhs | rhs)
}

public prefix func ~<V: Value>(rhs: SQLExpression<V>) -> SQLExpression<V> where V.Datatype == Int64 {
    Operator.bitwiseXor.wrap(rhs)
}
public prefix func ~<V: Value>(rhs: SQLExpression<V?>) -> SQLExpression<V?> where V.Datatype == Int64 {
    Operator.bitwiseXor.wrap(rhs)
}

// MARK: -

public func ==<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: SQLExpression<V?>, rhs: V?) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let rhs else { return "IS".infix(lhs, SQLExpression<V?>(value: nil)) }
    return Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.eq.infix(lhs, rhs)
}
public func ==<V: Value>(lhs: V?, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let lhs else { return "IS".infix(SQLExpression<V?>(value: nil), rhs) }
    return Operator.eq.infix(lhs, rhs)
}

public func ===<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: SQLExpression<V?>, rhs: V?) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let rhs else { return "IS".infix(lhs, SQLExpression<V?>(value: nil)) }
    return "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS".infix(lhs, rhs)
}
public func ===<V: Value>(lhs: V?, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let lhs else { return "IS".infix(SQLExpression<V?>(value: nil), rhs) }
    return "IS".infix(lhs, rhs)
}

public func !=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: SQLExpression<V?>, rhs: V?) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let rhs else { return "IS NOT".infix(lhs, SQLExpression<V?>(value: nil)) }
    return Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    Operator.neq.infix(lhs, rhs)
}
public func !=<V: Value>(lhs: V?, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let lhs else { return "IS NOT".infix(SQLExpression<V?>(value: nil), rhs) }
    return Operator.neq.infix(lhs, rhs)
}

public func !==<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: SQLExpression<V?>, rhs: V?) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let rhs else { return "IS NOT".infix(lhs, SQLExpression<V?>(value: nil)) }
    return "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Equatable {
    "IS NOT".infix(lhs, rhs)
}
public func !==<V: Value>(lhs: V?, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Equatable {
    guard let lhs else { return "IS NOT".infix(SQLExpression<V?>(value: nil), rhs) }
    return "IS NOT".infix(lhs, rhs)
}

public func ><V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}
public func ><V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gt.infix(lhs, rhs)
}

public func >=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}
public func >=<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.gte.infix(lhs, rhs)
}

public func <<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}
public func <<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lt.infix(lhs, rhs)
}

public func <=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: SQLExpression<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: SQLExpression<V?>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: SQLExpression<V>, rhs: V) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: SQLExpression<V?>, rhs: V) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: V, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}
public func <=<V: Value>(lhs: V, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable {
    Operator.lte.infix(lhs, rhs)
}

public func ~=<V: Value>(lhs: ClosedRange<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) BETWEEN ? AND ?", rhs.bindings + [lhs.lowerBound.datatypeValue, lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: ClosedRange<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) BETWEEN ? AND ?", rhs.bindings + [lhs.lowerBound.datatypeValue, lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: Range<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) >= ? AND \(rhs.template) < ?",
               rhs.bindings + [lhs.lowerBound.datatypeValue] + rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: Range<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) >= ? AND \(rhs.template) < ?",
               rhs.bindings + [lhs.lowerBound.datatypeValue] + rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeThrough<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) <= ?", rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeThrough<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) <= ?", rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeUpTo<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) < ?", rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeUpTo<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) < ?", rhs.bindings + [lhs.upperBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeFrom<V>, rhs: SQLExpression<V>) -> SQLExpression<Bool> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) >= ?", rhs.bindings + [lhs.lowerBound.datatypeValue])
}

public func ~=<V: Value>(lhs: PartialRangeFrom<V>, rhs: SQLExpression<V?>) -> SQLExpression<Bool?> where V.Datatype: Comparable & Value {
    SQLExpression("\(rhs.template) >= ?", rhs.bindings + [lhs.lowerBound.datatypeValue])
}

// MARK: -

public func and(_ terms: SQLExpression<Bool>...) -> SQLExpression<Bool> {
    "AND".infix(terms)
}
public func and(_ terms: [SQLExpression<Bool>]) -> SQLExpression<Bool> {
    "AND".infix(terms)
}
public func &&(lhs: SQLExpression<Bool>, rhs: SQLExpression<Bool>) -> SQLExpression<Bool> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: SQLExpression<Bool>, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: SQLExpression<Bool?>, rhs: SQLExpression<Bool>) -> SQLExpression<Bool?> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: SQLExpression<Bool?>, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: SQLExpression<Bool>, rhs: Bool) -> SQLExpression<Bool> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: SQLExpression<Bool?>, rhs: Bool) -> SQLExpression<Bool?> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: Bool, rhs: SQLExpression<Bool>) -> SQLExpression<Bool> {
    Operator.and.infix(lhs, rhs)
}
public func &&(lhs: Bool, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.and.infix(lhs, rhs)
}

public func or(_ terms: SQLExpression<Bool>...) -> SQLExpression<Bool> {
    "OR".infix(terms)
}
public func or(_ terms: [SQLExpression<Bool>]) -> SQLExpression<Bool> {
    "OR".infix(terms)
}
public func ||(lhs: SQLExpression<Bool>, rhs: SQLExpression<Bool>) -> SQLExpression<Bool> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: SQLExpression<Bool>, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: SQLExpression<Bool?>, rhs: SQLExpression<Bool>) -> SQLExpression<Bool?> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: SQLExpression<Bool?>, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: SQLExpression<Bool>, rhs: Bool) -> SQLExpression<Bool> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: SQLExpression<Bool?>, rhs: Bool) -> SQLExpression<Bool?> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: Bool, rhs: SQLExpression<Bool>) -> SQLExpression<Bool> {
    Operator.or.infix(lhs, rhs)
}
public func ||(lhs: Bool, rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.or.infix(lhs, rhs)
}

public prefix func !(rhs: SQLExpression<Bool>) -> SQLExpression<Bool> {
    Operator.not.wrap(rhs)
}

public prefix func !(rhs: SQLExpression<Bool?>) -> SQLExpression<Bool?> {
    Operator.not.wrap(rhs)
}
