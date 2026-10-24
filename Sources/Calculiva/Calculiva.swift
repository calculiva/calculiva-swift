// Calculiva home improvement estimators: mulch, topsoil and fill, sod.
//
// A line-by-line port of the Go module github.com/calculiva/calculiva-go
// (same version), itself a port of the engine of the calculators on
// https://calculiva.com/. Method: https://calculiva.com/how-we-calculate/
//
// All lengths are millimetres. Invalid input throws an `InputError` that names
// the offending field. The results are planning quantities: the manufacturer's
// instructions, the local code and the installer on site govern.

import Foundation

/// The version of the Go module this package follows.
public let calculivaVersion = "0.3.0"

/// One inch in millimetres (exact by definition of the international inch).
public let inch: Double = 25.4

/// One foot in millimetres (exact by definition of the international foot).
public let foot: Double = 304.8

/// An invalid input, with the name of the field that caused it.
public struct InputError: Error, Equatable, CustomStringConvertible {
    /// Human-readable, in English.
    public let message: String
    /// The offending field (for example "a1-depth" or "bag").
    public let field: String

    public init(message: String, field: String) {
        self.message = message
        self.field = field
    }

    /// The message followed by the field in parentheses.
    public var description: String { message + " (" + field + ")" }
}
