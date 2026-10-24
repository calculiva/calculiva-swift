import Foundation

// Number helpers shared by the estimators: tolerant rounding, range checks and
// the number formats used in error messages (Go: internal/num).

/// Absolute tolerance of the range checks, in the unit of the value.
let eps = 1e-7

/// Bounds of a plan length, mm, and the end of the message that states them.
let lenMin = 50.0
let lenMax = 60000.0
let lenMsg = " from 50 mm to 60 m (about 2 in to 196 ft)."

/// Rounds up, forgiving a relative 1e-9 of floating-point noise.
func ceilRel(_ n: Double) -> Double {
    (n - 1e-9 * max(abs(n), 1.0)).rounded(.up)
}

/// Rounds down, forgiving a relative 1e-9 of floating-point noise.
func floorRel(_ n: Double) -> Double {
    (n + 1e-9 * max(abs(n), 1.0)).rounded(.down)
}

/// Rounds up, forgiving eight ULPs.
func ceilULP(_ n: Double) -> Double {
    (n - Double.ulpOfOne * max(n, 1.0) * 8.0).rounded(.up)
}

func isWhole(_ v: Double) -> Bool {
    v == v.rounded(.towardZero)
}

/// Checks that v is a finite number within [lo, hi] (tolerance 1e-7).
func checkRange(_ v: Double, _ lo: Double, _ hi: Double, _ message: String, _ field: String) throws {
    if !v.isFinite || v < lo - eps || v > hi + eps {
        throw InputError(message: message, field: field)
    }
}

/// The shortest decimal that reads back as v, without exponent (Go:
/// strconv.FormatFloat(v, 'f', -1, 64) for the values used in messages).
func shortest(_ v: Double) -> String {
    if v.isFinite && isWhole(v) && abs(v) < 1e15 {
        return String(Int64(v))
    }
    return "\(v)"
}

/// JavaScript's String(n) for the values used in messages.
func jsNum(_ v: Double) -> String {
    shortest(v)
}

/// JavaScript's toLocaleString('en-US', {maximumFractionDigits}) for the
/// values used in messages: grouped thousands, trailing zeros removed.
func locale(_ v: Double, _ digits: Int) -> String {
    let s = String(format: "%.\(digits)f", v)
    var whole = s
    var frac = ""
    if let dot = s.firstIndex(of: ".") {
        whole = String(s[..<dot])
        frac = String(s[s.index(after: dot)...])
        while frac.hasSuffix("0") { frac.removeLast() }
    }
    let neg = whole.hasPrefix("-")
    let body = Array(whole.drop(while: { $0 == "-" }))
    var grouped = ""
    for (i, ch) in body.enumerated() {
        if i > 0 && (body.count - i) % 3 == 0 { grouped.append(",") }
        grouped.append(ch)
    }
    var out = ""
    if neg && (grouped.contains(where: { $0 != "0" && $0 != "," }) || !frac.isEmpty) {
        out += "-"
    }
    out += grouped
    if !frac.isEmpty { out += "." + frac }
    return out
}

/// Zero-padded decimal (Go: fmt "%03d").
func padded(_ n: Int, _ width: Int) -> String {
    let s = String(n)
    return String(repeating: "0", count: max(0, width - s.count)) + s
}
