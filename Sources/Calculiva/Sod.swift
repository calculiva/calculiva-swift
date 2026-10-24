import Foundation

/// Sod by area: staggered layout of rectangles with offcut reuse, areas by square
/// footage with an allowance, plugs (UF/IFAS Table 3), soil preparation, pallets,
/// cost and weight.
///
/// Lengths are millimetres. The allowances are entries of the user. The results
/// are planning quantities: the grower's pallet, the publishers quoted and the
/// installer on site govern.
///
/// Calculator page: https://calculiva.com/landscaping/sod-calculator/
public enum Sod {
    /// One square foot in mm².
    public static let sqFt = foot * foot
    static let yard = 3.0 * foot
    /// One square yard in mm².
    public static let sqYd = yard * yard
    /// One cubic foot in mm³.
    public static let cuFt = sqFt * foot
    /// One cubic yard in mm³.
    public static let cuYd = yard * yard * yard

    static let sqM = 1e6
    static let rectMax = 300.0 * foot
    static let pieceWMin = 4.0 * inch
    static let pieceWMax = 48.0 * inch
    static let pieceLMin = 12.0 * inch
    static let pieceLMax = 120.0 * inch

    /// A sod format as surveyed (inches and square feet as published). nil means
    /// the figure is not published for the format.
    public struct FormatRow: Encodable {
        public let id: String
        public let name: String
        public let widthIn: Double
        public let lengthIn: Double
        /// The square feet per piece as stated by the grower.
        public let statedSqFt: Double
        /// The pallet coverages as stated (slabs), square feet.
        public let palletsStatedSqFt: [Double]?
        /// The pieces per pallet as stated.
        public let piecesPerPallet: [Double]?
        /// The pallet coverages as sold, square feet.
        public let palletsSoldAsSqFt: [Double]?
    }

    /// The four surveyed sod formats.
    ///
    /// Data sheet sod-format-observations (formats), source
    /// https://sodsolutions.com/sod-university/square-feet-per-pallet/, verified 2026-09-25,
    /// market survey expiring 2027-03-25.
    public static let formats: [FormatRow] = [
        FormatRow(id: "slab-16x24", name: "Slab, 16 × 24 in", widthIn: 16.0, lengthIn: 24.0, statedSqFt: 2.66,
                  palletsStatedSqFt: [399.0, 452.0, 503.0], piecesPerPallet: nil, palletsSoldAsSqFt: [400.0, 450.0, 500.0]),
        FormatRow(id: "mini-roll-18x40", name: "Mini hand roll, 18 × 40 in", widthIn: 18.0, lengthIn: 40.0, statedSqFt: 5.0,
                  palletsStatedSqFt: nil, piecesPerPallet: [80.0, 90.0, 100.0], palletsSoldAsSqFt: [400.0, 450.0, 500.0]),
        FormatRow(id: "roll-24x60", name: "Roll, 24 × 60 in", widthIn: 24.0, lengthIn: 60.0, statedSqFt: 10.0,
                  palletsStatedSqFt: nil, piecesPerPallet: nil, palletsSoldAsSqFt: nil),
        FormatRow(id: "roll-18x80", name: "Roll, 18 × 80 in", widthIn: 18.0, lengthIn: 80.0, statedSqFt: 10.0,
                  palletsStatedSqFt: nil, piecesPerPallet: nil, palletsSoldAsSqFt: nil),
    ]

    /// The slabs on the three stated slab pallets (399, 452 and 503 sq ft at 2.66 sq ft).
    ///
    /// Data sheet sod-format-observations (derived.slab_pieces_per_stated_pallet), source
    /// https://sodsolutions.com/sod-university/square-feet-per-pallet/, verified 2026-09-25,
    /// market survey expiring 2027-03-25.
    public static let slabPiecesPerStatedPallet: [Double] = [150.0, 170.0, 189.0]

    /// The weight of one pallet of sod, pounds (a range).
    ///
    /// Data sheet sod-format-observations (source sodsolutions,
    /// https://sodsolutions.com/sod-university/square-feet-per-pallet/), verified 2026-09-25,
    /// market survey expiring 2027-03-25.
    public static let palletWeightLb: [Double] = [1500.0, 3000.0]

    /// The settled topsoil under new sod, inches (Penn State).
    ///
    /// Data sheet sod-installation-guidance (publisher psu), source
    /// https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
    public static let psuTopsoilSettledIn: [Double] = [4.0, 6.0]

    /// The organic matter layer to incorporate, inches (Penn State).
    ///
    /// Data sheet sod-installation-guidance (publisher psu), source
    /// https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
    public static let psuOrganicLayerIn: [Double] = [1.0, 2.0]

    /// The thickest organic layer to incorporate in a single pass, inches (Penn State).
    ///
    /// Data sheet sod-installation-guidance (publisher psu), source
    /// https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
    public static let psuOrganicLayerMaxSinglePassIn = 2.0

    /// The organic matter rate, cubic yards per 1,000 sq ft (NC State).
    ///
    /// Data sheet sod-installation-guidance (publisher ncsu, https://content.ces.ncsu.edu/carolina-lawns),
    /// sheet source https://extension.psu.edu/lawn-establishment/, verified 2026-09-25.
    public static let ncsuOrganicCuYdPer1000SqFt: [Double] = [1.0, 2.0]

    /// A row of UF/IFAS LH013 Table 3.
    public struct PlantingRow: Encodable {
        public let species: String
        public let method: String
        public let spacingIn: Double
        /// The square feet of sod per 1,000 sq ft of lawn (a range).
        public let sodSqFtPer1000: [Double]
    }

    /// UF/IFAS LH013 Table 3: plugs and sprigs by species.
    ///
    /// Data sheet sod-plugging-ifas (table3), source https://ask.ifas.ufl.edu/publication/LH013,
    /// verified 2026-09-25.
    public static let ifasTable3: [PlantingRow] = [
        PlantingRow(species: "St. Augustinegrass", method: "2-inch plugs", spacingIn: 12.0, sodSqFtPer1000: [30.0, 50.0]),
        PlantingRow(species: "St. Augustinegrass", method: "sprigs", spacingIn: 12.0, sodSqFtPer1000: [10.0, 15.0]),
        PlantingRow(species: "Centipedegrass", method: "2-inch plugs", spacingIn: 6.0, sodSqFtPer1000: [100.0, 150.0]),
        PlantingRow(species: "Centipedegrass", method: "sprigs", spacingIn: 6.0, sodSqFtPer1000: [30.0, 50.0]),
        PlantingRow(species: "Zoysiagrass", method: "2-inch plugs", spacingIn: 6.0, sodSqFtPer1000: [100.0, 150.0]),
        PlantingRow(species: "Zoysiagrass", method: "sprigs", spacingIn: 6.0, sodSqFtPer1000: [8.0, 15.0]),
        PlantingRow(species: "Bermudagrass", method: "2-inch plugs", spacingIn: 12.0, sodSqFtPer1000: [30.0, 50.0]),
        PlantingRow(species: "Bermudagrass", method: "sprigs", spacingIn: 12.0, sodSqFtPer1000: [2.0, 5.0]),
    ]

    /// The number of two-inch plugs cut from one square yard of sod.
    ///
    /// Data sheet sod-plugging-ifas (conversions.two_inch_plugs_per_sqyd), source
    /// https://ask.ifas.ufl.edu/publication/LH013, verified 2026-09-25.
    public static let twoInchPlugsPerSqYd = 324.0

    /// The plug sizes offered, inches: UF/IFAS LH013 "2-to-4-inch" plugs.
    ///
    /// Data sheet sod-plugging-ifas, source https://ask.ifas.ufl.edu/publication/LH013, verified 2026-09-25.
    public static let plugSizesIn: [Double] = [2.0, 3.0, 4.0]

    /// A sod format in millimetres, with its pallets. nil means the figure is not
    /// known for the format.
    public struct Format: Encodable {
        public let id: String
        public let name: String
        public let widthMM: Double
        public let lengthMM: Double
        public let statedSqFt: Double
        public let palletPieces: [Double]?
        public let palletSqFt: [Double]?
        public let soldAsSqFt: [Double]?
    }

    /// A plugging species.
    public struct Species: Encodable {
        /// The slug of the species name.
        public let id: String
        public let species: String
        /// The table spacing, mm.
        public let spacingMM: Double
        /// The plug size of the table row, inches.
        public let plugIn: Double
        public let sodSqFtPer1000: [Double]
    }

    /// The rules of the sod calculator.
    public struct Rules: Encodable {
        public var formats: [Format]
        /// The default allowance, percent: an entry of the user, 0 unless set.
        public var allowance: Double
        /// The allowance for complex shapes, percent: an entry of the user, 0 unless set.
        public var allowanceComplex: Double
        public var palletLb: [Double]
        public var topsoilMM: [Double]
        public var organicLayerMM: [Double]
        public var organicLayerMaxMM: Double
        /// cu yd per 1,000 sq ft.
        public var organicRate: [Double]
        public var species: [Species]
        public var plugsPerSqYd2In: Double
        public var plugSizes: [Double]
    }

    static func slug(_ s: String) -> String {
        var out = ""
        var dash = false
        for ch in s.lowercased() {
            if ("a"..."z").contains(ch) || ("0"..."9").contains(ch) {
                if dash && !out.isEmpty { out.append("-") }
                dash = false
                out.append(ch)
            } else {
                dash = true
            }
        }
        return out
    }

    static func leadingNumber(_ s: String) -> Double {
        let head = s.prefix { ("0"..."9").contains($0) || $0 == "." }
        return Double(String(head)) ?? Double.nan
    }

    /// Builds the sod rules from the sourced constants. `allowance` and
    /// `allowanceComplex` are left at 0 for the user to set.
    public static func newRules() -> Rules {
        let fs = formats.map { f -> Format in
            Format(
                id: f.id, name: f.name,
                widthMM: f.widthIn * inch, lengthMM: f.lengthIn * inch, statedSqFt: f.statedSqFt,
                palletPieces: f.palletsStatedSqFt != nil ? slabPiecesPerStatedPallet : f.piecesPerPallet,
                palletSqFt: f.palletsStatedSqFt ?? f.palletsSoldAsSqFt,
                soldAsSqFt: f.palletsSoldAsSqFt
            )
        }
        let species = ifasTable3.filter { $0.method.contains("plug") }.map { r in
            Species(id: slug(r.species), species: r.species, spacingMM: r.spacingIn * inch,
                    plugIn: leadingNumber(r.method), sodSqFtPer1000: r.sodSqFtPer1000)
        }
        return Rules(
            formats: fs,
            allowance: 0.0,
            allowanceComplex: 0.0,
            palletLb: palletWeightLb,
            topsoilMM: [psuTopsoilSettledIn[0] * inch, psuTopsoilSettledIn[1] * inch],
            organicLayerMM: [psuOrganicLayerIn[0] * inch, psuOrganicLayerIn[1] * inch],
            organicLayerMaxMM: psuOrganicLayerMaxSinglePassIn * inch,
            organicRate: ncsuOrganicCuYdPer1000SqFt,
            species: species,
            plugsPerSqYd2In: twoInchPlugsPerSqYd,
            plugSizes: plugSizesIn
        )
    }

    /// One placed piece of a rectangle layout.
    public struct Piece: Encodable {
        /// P001, P002 and so on.
        public let id: String
        public let row: String
        /// The laid length, mm.
        public let length: Double
        /// The laid width, mm.
        public let width: Double
        /// full, isolated, start or end.
        public let role: String
        public let cut: Bool
        /// The bought piece it comes from (B001, or strip source S001).
        public let buy: String
        /// Whether that bought piece is shared with another placed piece.
        public let shared: Bool
    }

    /// A row of a rectangle layout.
    public struct Row: Encodable {
        /// R01, R02 and so on.
        public let id: String
        public let width: Double
        /// The offset of the row across the area, mm.
        public let across: Double
    }

    /// The layout of one rectangle.
    public struct RectLayout: Encodable {
        public let pieces: [Piece]
        public let rows: [Row]
        public let installed: Int
        public let cut: Int
        public let full: Int
        /// Start and end offcuts paired in one piece.
        public let pairs: Int
        /// Narrow full-length strips of the last row.
        public let strips: Int
        /// Pieces bought for those strips.
        public let stripBought: Int
        public let bought: Int
    }

    /// Lays a rectangle: staggered rows at half a piece, then the narrow
    /// full-length strips of the last row grouped floor(piece width / strip width)
    /// per bought piece (UF/IFAS: offcuts fill the joints; a strip taken from a
    /// piece leaves a strip).
    public static func layRect(l: Double, w: Double, pieceW: Double, pieceL: Double) throws -> RectLayout {
        let fp = try staggered(roomW: l, roomH: w, plankW: pieceW, plankL: pieceL, offset: 0.5, maxRoom: rectMax, maxPlankW: pieceWMax)
        var index: [String: Int] = [:]
        for (i, p) in fp.pieces.enumerated() {
            index[p.id] = i
        }
        var buy = [String](repeating: "", count: fp.pieces.count)
        var shared = [Bool](repeating: false, count: fp.pieces.count)
        var groups: [(key: String, width: Double, ids: [Int])] = []
        var kept = 0
        for s in fp.sources {
            let i = index[s.pieces[0]]!
            let p = fp.pieces[i]
            if !s.pair && p.role == .full && p.width < pieceW - eps {
                let k = String(format: "%.3f", p.width)
                if let g = groups.firstIndex(where: { $0.key == k }) {
                    groups[g].ids.append(i)
                } else {
                    groups.append((key: k, width: p.width, ids: [i]))
                }
                continue
            }
            kept += 1
            for id in s.pieces {
                let j = index[id]!
                buy[j] = s.id
                shared[j] = s.pair
            }
        }
        var strips = 0
        var stripBought = 0
        var n = 0
        for g in groups {
            let per = Int(max(floorRel(pieceW / g.width), 1.0))
            let bought = Int(ceilRel(Double(g.ids.count) / Double(per)))
            strips += g.ids.count
            stripBought += bought
            for (k, i) in g.ids.enumerated() {
                buy[i] = "S" + padded(n + k / per + 1, 3)
                shared[i] = per > 1 && g.ids.count > 1
            }
            n += bought
        }
        var pieces: [Piece] = []
        var cut = 0
        for (i, p) in fp.pieces.enumerated() {
            pieces.append(Piece(id: p.id, row: p.row, length: p.length, width: p.width, role: p.role.rawValue,
                                cut: p.cut, buy: buy[i], shared: shared[i]))
            if p.cut { cut += 1 }
        }
        let pairs = fp.sources.filter { $0.pair }.count
        let rows = fp.rows.map { Row(id: $0.id, width: $0.width, across: $0.across) }
        return RectLayout(pieces: pieces, rows: rows, installed: pieces.count, cut: cut, full: pieces.count - cut,
                          pairs: pairs, strips: strips, stripBought: stripBought, bought: kept + stripBought)
    }

    /// The shape of a sod area, lengths in mm.
    public enum Shape {
        /// A rectangle, laid out piece by piece; `count` copies (1 to 20).
        case rect(l: Double, w: Double, count: Double)
        /// A circle of radius r.
        case circle(r: Double, count: Double)
        case triangle(b: Double, h: Double, count: Double)
        /// A known area, mm².
        case knownArea(Double)
    }

    /// One sod area.
    public struct Area {
        /// Prefixes error fields.
        public var id: String
        public var shape: Shape

        public init(id: String, shape: Shape) {
            self.id = id
            self.shape = shape
        }
    }

    /// How a pallet is sold.
    public enum PalletMode: String, Encodable {
        case byPieces = "pieces"
        case bySqFt = "sqFt"
    }

    /// Solid sod or plugs.
    public enum Method: String, Encodable {
        case solid
        case plugs
    }

    /// How organic matter is given.
    public enum Organic: String, Encodable {
        /// As a layer depth.
        case layer
        /// As cubic yards per 1,000 sq ft.
        case rate
        case none
    }

    /// How the price is quoted.
    public enum PriceMode: String, Encodable {
        case perPallet
        case perPiece
        case perSqFt
    }

    /// The input of `newPlan`. Build it with `newInput` to get the calculator defaults.
    public struct Input: Encodable {
        /// One to eight areas.
        public var areas: [Area]
        /// A format id of the rules, or "custom".
        public var format: String
        /// The custom piece width, mm.
        public var pieceW: Double = 0.0
        /// The custom piece length, mm.
        public var pieceL: Double = 0.0
        public var palletMode: PalletMode = .byPieces
        /// Pieces per pallet (whole number).
        public var palletPieces: Double = 0.0
        public var palletSqFt: Double = 0.0
        /// The allowance on areas without a layout, percent.
        public var allowance: Double = 0.0
        /// The spare on laid-out rectangles, percent.
        public var spare: Double = 0.0
        public var method: Method = .solid
        /// A species id of the rules, or "custom".
        public var species: String
        /// The plug spacing, mm.
        public var spacing: Double
        /// The plug size, inches.
        public var plugSize: Double
        /// The topsoil depth, mm.
        public var topsoil: Double
        public var organic: Organic = .layer
        /// The organic layer, mm.
        public var organicIn: Double
        /// cu yd per 1,000 sq ft.
        public var organicRate: Double
        public var priceMode: PriceMode = .perPallet
        public var price: Double = 0.0
        public var delivery: Double = 0.0
        /// The vehicle payload, lb, 0 for none.
        public var payload: Double = 0.0

        enum CodingKeys: String, CodingKey {
            case format, pieceW, pieceL, palletMode, palletPieces, palletSqFt, allowance, spare, method, species
            case spacing, plugSize, topsoil, organic, organicIn, organicRate, priceMode, price, delivery, payload
        }
    }

    /// An input with the calculator defaults taken from the rules (first format,
    /// rule allowance, first species, lower topsoil and organic values).
    /// `palletPieces` starts at 0 and must be set.
    public static func newInput(areas: [Area], rules: Rules) -> Input {
        let sp = rules.species[0]
        return Input(
            areas: areas,
            format: rules.formats[0].id,
            allowance: rules.allowance,
            species: sp.id,
            spacing: sp.spacingMM,
            plugSize: sp.plugIn,
            topsoil: rules.topsoilMM[0],
            organicIn: rules.organicLayerMM[0],
            organicRate: rules.organicRate[0]
        )
    }

    /// How an area was counted.
    public enum Mode: String, Encodable {
        /// Plugs: counted over the whole lawn.
        case plugs
        /// Laid out piece by piece.
        case layout
        /// Counted by area with the allowance.
        case area
        /// A rectangle too large to lay out, counted by area.
        case noLayout
    }

    /// One area's result, in the order of the input.
    public struct AreaPlan: Encodable {
        public let id: String
        public let count: Double
        /// One copy, mm².
        public let areaMM2: Double
        /// All copies, sq ft.
        public let sqFt: Double
        public var mode: Mode = .plugs
        /// For laid-out rectangles; nil otherwise.
        public var layout: RectLayout?
        /// Pieces bought.
        public var bought: Double = 0.0
        /// The extra over the area, percent; nil for plugs.
        public var extraPct: Double?
    }

    /// The totals.
    public struct Totals: Encodable {
        public let areaMM2: Double
        public let sqFt: Double
        public let layoutBought: Double
        public let areaBought: Double
        public let spare: Double
        /// Pieces to buy.
        public let pieces: Double
        /// The flat count at the rule allowance, for comparison.
        public let flat: Double
    }

    /// The pallet count.
    public struct Pallets: Encodable {
        public let perPallet: Double
        public let full: Double
        /// Loose pieces over the full pallets.
        public let loose: Double
        public let palletsUp: Double
        /// Pieces left on the last pallet.
        public let leftover: Double
    }

    /// The plug result.
    public struct PlugPlan: Encodable {
        /// nil when custom.
        public let species: Species?
        public let count: Double
        public let sodSqFt: Double
        public let sodSqYd: Double
        public let perSqYd: Double
        public let pieces: Double
        /// The table sod range for this lawn, sq ft; nil when the table has no
        /// row for the species and plug size.
        public let tableSqFt: [Double]?
        public let tablePieces: [Double]?
    }

    /// The soil preparation. At most one of the two equivalents is set.
    public struct Prep: Encodable {
        public let topsoilMM3: Double
        public let topsoilCuFt: Double
        public let topsoilCuYd: Double
        public let organicMM3: Double
        public let organicCuFt: Double
        public let organicCuYd: Double
        /// cu yd per 1,000 sq ft, when the organic matter was given as a layer.
        public let equivalentRate: Double?
        /// mm, when the organic matter was given as a rate.
        public let equivalentLayerMM: Double?
    }

    /// The cost. nil means the value is absent.
    public struct Cost: Encodable {
        public let perPiece: Double?
        /// Whole pallets plus delivery.
        public let whole: Double?
        /// Full pallets plus loose pieces plus delivery.
        public let mixed: Double?
    }

    /// The short kind of a warning, as used on the calculator page.
    public enum WarningKind: String, Encodable {
        case noLayout = "no-layout"
        case spacing
        case organicThick = "organic-thick"
        case rateOutside = "rate-outside"
        case topsoilThin = "topsoil-thin"
    }

    /// A planning warning. The fields that do not belong to its kind are zero.
    public struct Warning: Encodable {
        public var kind: WarningKind
        public var area = ""
        public var species = ""
        public var spacing = 0.0
        public var tableMM = 0.0
        public var layer = 0.0
        public var maxMM = 0.0
        public var rate = 0.0
        public var range: [Double] = [0.0, 0.0]
        public var topsoil = 0.0
        public var minMM = 0.0
    }

    /// The result of `newPlan`.
    public struct Plan: Encodable {
        public let pieceW: Double
        public let pieceL: Double
        public let pieceMM2: Double
        public let pieceSqFt: Double
        public let perPallet: Double
        public let areas: [AreaPlan]
        public let totals: Totals
        public let pallets: Pallets
        /// When planting plugs; nil otherwise.
        public let plug: PlugPlan?
        public let prep: Prep
        public let cost: Cost
        /// The weight range of the pallets, lb.
        public let weightLb: [Double]
        /// Trips for each end of the weight range; nil without a payload.
        public let trips: [Double]?
        public let warnings: [Warning]
    }

    static func tidy(_ x: Double) -> Double {
        abs(x) < 1e-9 ? 0.0 : x
    }

    /// Plans sod: pieces per area, pallets, plugs, soil preparation, cost and weight.
    public static func newPlan(_ c: Input, rules: Rules) throws -> Plan {
        if c.areas.isEmpty || c.areas.count > 8 {
            throw InputError(message: "Tick one to eight areas.", field: "areas")
        }
        // Format: one of the surveyed formats, or a piece entered by hand.
        let pieceW: Double
        let pieceL: Double
        if let f = rules.formats.first(where: { $0.id == c.format }) {
            pieceW = f.widthMM
            pieceL = f.lengthMM
        } else {
            if c.format != "custom" {
                throw InputError(message: "Choose a sod format.", field: "format")
            }
            try checkRange(c.pieceW, pieceWMin, pieceWMax, "Enter a piece width from 4 to 48 in (102 to 1,219 mm).", "piece-w")
            try checkRange(c.pieceL, pieceLMin, pieceLMax, "Enter a piece length from 12 to 120 in (305 to 3,048 mm).", "piece-l")
            pieceW = c.pieceW
            pieceL = c.pieceL
        }
        let pieceMM2 = pieceW * pieceL
        let pieceSqFt = pieceMM2 / sqFt
        let perPallet: Double
        if c.palletMode == .bySqFt {
            try checkRange(c.palletSqFt, 50.0, 2000.0, "Enter a pallet coverage from 50 to 2,000 sq ft.", "pallet-sqft")
            perPallet = floorRel(c.palletSqFt / pieceSqFt)
            if perPallet < 1.0 {
                throw InputError(message: "The pallet holds less than one piece of this size.", field: "pallet-sqft")
            }
        } else {
            if !isWhole(c.palletPieces) || c.palletPieces < 1.0 || c.palletPieces > 2000.0 {
                throw InputError(message: "Enter a whole number of pieces per pallet from 1 to 2,000.", field: "pallet-pieces")
            }
            perPallet = c.palletPieces
        }
        try checkRange(c.allowance, 0.0, 30.0, "Enter an allowance from 0 to 30 %.", "allowance")
        try checkRange(c.spare, 0.0, 30.0, "Enter a spare from 0 to 30 %.", "spare")
        let plugs = c.method == .plugs
        var warnings: [Warning] = []
        var areas: [AreaPlan] = []
        for a in c.areas {
            func f(_ k: String) -> String { a.id + "-" + k }
            func length(_ v: Double, _ k: String, _ label: String, _ mx: Double) throws {
                let msg = "Enter \(label) from 1 to \(shortest(mx / foot)) ft (0.3 to \(locale(mx / 1000.0, 1)) m)."
                try checkRange(v, foot, mx, msg, f(k))
            }
            func copies(_ count: Double) throws {
                if !isWhole(count) || !(count >= 1.0 && count <= 20.0) {
                    throw InputError(message: "Enter a whole number of copies from 1 to 20.", field: f("count"))
                }
            }
            var count = 1.0
            var layout: RectLayout?
            var noLayout = false
            let areaMM2: Double
            switch a.shape {
            case let .rect(l, w, n):
                try copies(n)
                count = n
                try length(l, "l", "a length", rectMax)
                try length(w, "w", "a width", rectMax)
                // Beyond 2,500 placed pieces, the drawing gives way to a count by area.
                if !plugs {
                    if ceilRel(l / pieceL + 1.0) * ceilRel(w / pieceW) > Double(maxPieces) {
                        noLayout = true
                        warnings.append(Warning(kind: .noLayout, area: a.id))
                    } else {
                        layout = try layRect(l: l, w: w, pieceW: pieceW, pieceL: pieceL)
                    }
                }
                areaMM2 = l * w
            case let .circle(r, n):
                try copies(n)
                count = n
                try length(r, "r", "a radius", 150.0 * foot)
                areaMM2 = Double.pi * r * r
            case let .triangle(b, h, n):
                try copies(n)
                count = n
                try length(b, "b", "a base", rectMax)
                try length(h, "h", "a height", rectMax)
                areaMM2 = b * h / 2.0
            case let .knownArea(area):
                try checkRange(area, 0.1 * sqM, 10000.0 * sqM, "Enter an area from 0.1 to 10,000 m² (about 1.1 to 107,639 sq ft).", f("area"))
                areaMM2 = area
            }
            let sqft = areaMM2 * count / sqFt
            var plan = AreaPlan(id: a.id, count: count, areaMM2: areaMM2, sqFt: sqft)
            if plugs {
                // counted over the whole lawn below
            } else if let lay = layout {
                let b = Double(lay.bought)
                plan.mode = .layout
                plan.bought = b * count
                plan.extraPct = tidy((b * pieceMM2 - areaMM2) / areaMM2 * 100.0)
                plan.layout = lay
            } else {
                let bought = ceilRel(sqft * (1.0 + c.allowance / 100.0) / pieceSqFt)
                plan.mode = noLayout ? .noLayout : .area
                plan.bought = bought
                plan.extraPct = tidy((bought * pieceSqFt - sqft) / sqft * 100.0)
            }
            areas.append(plan)
        }
        var lawnMM2 = 0.0
        var layoutBought = 0.0
        var areaBought = 0.0
        for a in areas {
            lawnMM2 += a.areaMM2 * a.count
            switch a.mode {
            case .layout: layoutBought += a.bought
            case .area, .noLayout: areaBought += a.bought
            case .plugs: break
            }
        }
        let lawnSqFt = lawnMM2 / sqFt
        let spare = plugs ? 0.0 : ceilRel(layoutBought * c.spare / 100.0)
        let flat = ceilRel(lawnSqFt * (1.0 + rules.allowance / 100.0) / pieceSqFt)
        var plug: PlugPlan?
        if plugs {
            var sp: Species?
            if c.species != "custom" {
                sp = rules.species.first { $0.id == c.species }
                if sp == nil {
                    throw InputError(message: "Choose a grass species.", field: "species")
                }
            }
            try checkRange(c.spacing, 4.0 * inch, 24.0 * inch, "Enter a plug spacing from 4 to 24 in (102 to 610 mm).", "spacing")
            if !rules.plugSizes.contains(c.plugSize) {
                throw InputError(message: "Choose a 2, 3 or 4 in plug.", field: "plug-size")
            }
            let plugMM = c.plugSize * inch
            let n = ceilRel(lawnMM2 / (c.spacing * c.spacing))
            let sodSqFt = n * plugMM * plugMM / sqFt
            var tableSqFt: [Double]?
            var tablePieces: [Double]?
            if let s = sp, c.plugSize == s.plugIn {
                let t = [s.sodSqFtPer1000[0] * lawnSqFt / 1000.0, s.sodSqFtPer1000[1] * lawnSqFt / 1000.0]
                tableSqFt = t
                tablePieces = [ceilRel(t[0] / pieceSqFt), ceilRel(t[1] / pieceSqFt)]
            }
            if let s = sp, abs(c.spacing - s.spacingMM) > eps {
                warnings.append(Warning(kind: .spacing, species: s.species, spacing: c.spacing, tableMM: s.spacingMM))
            }
            plug = PlugPlan(species: sp, count: n, sodSqFt: sodSqFt, sodSqYd: sodSqFt * sqFt / sqYd,
                            perSqYd: sqYd / (plugMM * plugMM), pieces: ceilRel(sodSqFt / pieceSqFt),
                            tableSqFt: tableSqFt, tablePieces: tablePieces)
        }
        var pieces = layoutBought + areaBought + spare
        if let p = plug { pieces = p.pieces }
        let full = floorRel(pieces / perPallet)
        let loose = pieces - full * perPallet
        let palletsUp = ceilRel(pieces / perPallet)
        let leftover = palletsUp * perPallet - pieces
        // Soil preparation over the whole lawn: topsoil (Penn State), organic matter as a layer
        // (Penn State) or as a rate per 1,000 sq ft (NC State), with the other publisher's equivalent.
        try checkRange(c.topsoil, 0.0, 12.0 * inch, "Enter a topsoil depth from 0 to 12 in (0 to 305 mm).", "topsoil")
        var organicMM3 = 0.0
        var equivalentRate: Double?
        var equivalentLayerMM: Double?
        switch c.organic {
        case .layer:
            try checkRange(c.organicIn, 0.0, 4.0 * inch, "Enter an organic layer from 0 to 4 in (0 to 102 mm).", "organic-in")
            organicMM3 = lawnMM2 * c.organicIn
            equivalentRate = organicMM3 / cuYd / (lawnSqFt / 1000.0)
            if c.organicIn > rules.organicLayerMaxMM + eps {
                warnings.append(Warning(kind: .organicThick, layer: c.organicIn, maxMM: rules.organicLayerMaxMM))
            }
        case .rate:
            try checkRange(c.organicRate, 0.0, 4.0, "Enter a rate from 0 to 4 cu yd per 1,000 sq ft.", "organic-rate")
            organicMM3 = c.organicRate * lawnSqFt / 1000.0 * cuYd
            equivalentLayerMM = organicMM3 / lawnMM2
            let lo = rules.organicRate[0]
            let hi = rules.organicRate[1]
            if c.organicRate < lo - eps || c.organicRate > hi + eps {
                warnings.append(Warning(kind: .rateOutside, rate: c.organicRate, range: rules.organicRate))
            }
        case .none:
            break
        }
        if c.topsoil > eps && c.topsoil < rules.topsoilMM[0] - eps {
            warnings.append(Warning(kind: .topsoilThin, topsoil: c.topsoil, minMM: rules.topsoilMM[0]))
        }
        let topsoilMM3 = lawnMM2 * c.topsoil
        let prep = Prep(topsoilMM3: topsoilMM3, topsoilCuFt: topsoilMM3 / cuFt, topsoilCuYd: topsoilMM3 / cuYd,
                        organicMM3: organicMM3, organicCuFt: organicMM3 / cuFt, organicCuYd: organicMM3 / cuYd,
                        equivalentRate: equivalentRate, equivalentLayerMM: equivalentLayerMM)
        // Cost: whole pallets, or full pallets plus loose pieces when priced per piece or per sq ft.
        try checkRange(c.price, 0.0, 10000.0, "Enter a price from 0 to 10,000 USD.", "price")
        try checkRange(c.delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
        var perPiece: Double?
        var whole: Double?
        var mixed: Double?
        switch c.priceMode {
        case .perPiece: perPiece = c.price
        case .perSqFt: perPiece = c.price * pieceSqFt
        case .perPallet: break
        }
        if c.price != 0.0 {
            if let each = perPiece {
                whole = palletsUp * perPallet * each + c.delivery
                mixed = pieces * each + c.delivery
            } else {
                whole = palletsUp * c.price + c.delivery
            }
        }
        // Weight: a range per pallet, never a single number.
        if c.payload != 0.0 {
            try checkRange(c.payload, 100.0, 10000.0, "Enter a payload from 100 to 10,000 lb, or 0.", "payload")
        }
        let weightLb = [rules.palletLb[0] * palletsUp, rules.palletLb[1] * palletsUp]
        var trips: [Double]?
        if c.payload != 0.0 {
            trips = [ceilRel(weightLb[0] / c.payload), ceilRel(weightLb[1] / c.payload)]
        }
        return Plan(
            pieceW: pieceW, pieceL: pieceL, pieceMM2: pieceMM2, pieceSqFt: pieceSqFt, perPallet: perPallet,
            areas: areas,
            totals: Totals(areaMM2: lawnMM2, sqFt: lawnSqFt, layoutBought: layoutBought, areaBought: areaBought,
                           spare: spare, pieces: pieces, flat: flat),
            pallets: Pallets(perPallet: perPallet, full: full, loose: loose, palletsUp: palletsUp, leftover: leftover),
            plug: plug, prep: prep, cost: Cost(perPiece: perPiece, whole: whole, mixed: mixed),
            weightLb: weightLb, trips: trips, warnings: warnings
        )
    }

    /// One row of `formatTable`.
    public struct FormatTableRow: Encodable {
        public let format: Format
        /// The exact square feet per piece.
        public let sqFt: Double
        /// Pieces for each pallet coverage asked.
        public let perPallet: [Double]
        /// Pieces for the lawn.
        public let forLawn: Double
    }

    /// The formats: square feet per piece, pieces for each pallet coverage in
    /// soldAs, pieces for the lawn.
    public static func formatTable(rules: Rules, soldAs: [Double], sqft: Double) -> [FormatTableRow] {
        rules.formats.map { f in
            let s = f.widthMM * f.lengthMM / sqFt
            return FormatTableRow(format: f, sqFt: s, perPallet: soldAs.map { ceilRel($0 / s) }, forLawn: ceilRel(sqft / s))
        }
    }
}
