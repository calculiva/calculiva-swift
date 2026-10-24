import Foundation

// The staggered row layout used by Sod.layRect: horizontal rows, unbalanced edge
// row, no gap, no kerf, factory-end pairing of start and end offcuts.

/// The upper bound on individually placed pieces in one layout.
let maxPieces = 2500

enum PlankRole: String {
    case full
    case isolated
    case start
    case end
}

struct Plank {
    let id: String
    let row: String
    let length: Double
    let width: Double
    let role: PlankRole
    let cut: Bool
}

struct StaggeredRow {
    let id: String
    let width: Double
    let across: Double
}

struct PieceSource {
    let id: String
    let pieces: [String]
    let pair: Bool
}

struct StaggeredLayout {
    let rows: [StaggeredRow]
    let pieces: [Plank]
    let sources: [PieceSource]
}

func positive(_ v: Double, _ key: String, _ label: String, _ lo: Double, _ hi: Double) throws {
    if !v.isFinite || v < lo || v > hi {
        throw InputError(message: "Enter \(label) between \(shortest(lo)) and \(shortest(hi)) mm.", field: key)
    }
}

func rowWidths(_ span: Double, _ width: Double) throws -> [Double] {
    if !(span > 0.0 && width > 0.0) {
        throw InputError(message: "The usable width must be positive.", field: "roomW")
    }
    let n = ceilULP(span / width)
    if n == 1.0 {
        return [span]
    }
    let last = span - (n - 1.0) * width
    return [Double](repeating: width, count: Int(n) - 1) + [last]
}

/// Pairs start and end offcuts that fit one piece. Each pair uses opposite
/// factory ends; no same-end pairing or face flipping.
func pairCuts(_ pieces: [Plank], _ length: Double) -> [PieceSource] {
    var sources: [PieceSource] = []
    var assigned = [Bool](repeating: false, count: pieces.count)
    func add(_ idx: [Int]) {
        for i in idx { assigned[i] = true }
        sources.append(PieceSource(id: "B" + padded(sources.count + 1, 3), pieces: idx.map { pieces[$0].id }, pair: idx.count == 2))
    }
    // Longest start first; a stable sort, ties keep their order.
    let starts = pieces.indices
        .filter { pieces[$0].role == .start }
        .enumerated()
        .sorted { x, y in
            let a = pieces[x.element].length
            let b = pieces[y.element].length
            return a != b ? a > b : x.offset < y.offset
        }
        .map { $0.element }
    for a in starts {
        var best = -1
        for (i, p) in pieces.enumerated() {
            if p.role == .end && !assigned[i] && p.length + pieces[a].length <= length + eps {
                if best < 0 || !(pieces[best].length >= p.length) {
                    best = i
                }
            }
        }
        if best >= 0 {
            add([best, a])
        }
    }
    for i in pieces.indices where !assigned[i] {
        add([i])
    }
    return sources
}

/// Lays horizontal staggered rows over roomW x roomH, the first row starting
/// with a full plank, offset of a plank per row, start and end offcuts paired
/// when they fit one plank.
func staggered(roomW: Double, roomH: Double, plankW: Double, plankL: Double, offset: Double,
               maxRoom: Double, maxPlankW: Double) throws -> StaggeredLayout {
    try positive(roomW, "roomW", "the room width", 10.0, maxRoom)
    try positive(roomH, "roomH", "the room length", 10.0, maxRoom)
    try positive(plankW, "plankW", "the plank width", 10.0, maxPlankW)
    try positive(plankL, "plankL", "the plank length", 10.0, 6000.0)
    let first = plankL
    let span = roomH
    let run = roomW
    let widths = try rowWidths(span, plankW)
    if widths.count > maxPieces {
        throw InputError(message: "Use a larger plank or a smaller field.", field: "plankW")
    }
    var rows: [StaggeredRow] = []
    var pieces: [Plank] = []
    var across = 0.0
    for (index, width) in widths.enumerated() {
        let phase = first + Double(index) * offset * plankL
        var start = (phase.truncatingRemainder(dividingBy: plankL) + plankL).truncatingRemainder(dividingBy: plankL)
        if start < eps || plankL - start < eps {
            start = plankL
        }
        let rowID = "R" + padded(index + 1, 2)
        var pos = 0.0
        while pos < run - eps {
            if pieces.count >= maxPieces {
                throw InputError(message: "This field exceeds 2,500 placed planks.", field: "roomW")
            }
            let proposed = pos == 0.0 ? start : plankL
            let length = min(proposed, run - pos)
            let atStart = pos < eps
            let atEnd = pos + length >= run - eps
            let role: PlankRole
            if length >= plankL - eps {
                role = .full
            } else if atStart && atEnd {
                role = .isolated
            } else if atStart {
                role = .start
            } else {
                role = .end
            }
            pieces.append(Plank(id: "P" + padded(pieces.count + 1, 3), row: rowID, length: length, width: width, role: role,
                                cut: length < plankL - eps || width < plankW - eps))
            pos += length
        }
        rows.append(StaggeredRow(id: rowID, width: width, across: across))
        across += width
    }
    return StaggeredLayout(rows: rows, pieces: pieces, sources: pairCuts(pieces, plankL))
}
