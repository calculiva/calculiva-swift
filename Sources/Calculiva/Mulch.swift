import Foundation

/// Mulch by area: beds, tree rings, known areas, play structures and swings (CPSC).
///
/// Lengths are millimetres; sale volumes are cubic feet and cubic yards. Mulch is
/// sold by volume: no weight here. The results are planning quantities: the
/// product label, the publishers quoted and the site govern.
///
/// Calculator page: https://calculiva.com/landscaping/mulch-calculator/
public enum Mulch {
    static let depthMin = 3.0
    static let depthMax = 600.0
    static let depthMsg = "Enter a depth from 1/8 in to about 24 in (3 to 600 mm)."
    static let existingMsg = "Enter the depth already in place from 0 to about 24 in (600 mm)."

    /// A minimum ring radius for one tree size.
    public struct TreeRadius: Encodable {
        /// small, medium or large.
        public let size: String
        /// The minimum ring radius, feet.
        public let ft: Double
    }

    /// A publisher's mulch guidance. nil means the publisher gives no such figure.
    public struct Publisher: Encodable {
        public let id: String
        public let name: String
        public let sourceURL: String
        /// The depth range for coarse mulch, inches.
        public let depthIn: [Double]?
        /// The depth range for fine mulch, inches.
        public let fineDepthIn: [Double]?
        /// The bare gap at the trunk, inches (a range counts by its minimum).
        public let trunkGapIn: [Double]?
        /// The minimum ring radius by tree size, feet.
        public let ringRadiusByTreeFt: [TreeRadius]?

        init(_ id: String, _ name: String, _ sourceURL: String, depthIn: [Double]? = nil, fineDepthIn: [Double]? = nil,
             trunkGapIn: [Double]? = nil, ringRadiusByTreeFt: [TreeRadius]? = nil) {
            self.id = id
            self.name = name
            self.sourceURL = sourceURL
            self.depthIn = depthIn
            self.fineDepthIn = fineDepthIn
            self.trunkGapIn = trunkGapIn
            self.ringRadiusByTreeFt = ringRadiusByTreeFt
        }
    }

    /// The mulch depth and trunk-gap guidance, publisher by publisher. A single
    /// published value v is stored as the range [v, v]; Casey Trees and Maple
    /// Grove publish it inside their 3-3-3 rule.
    ///
    /// Data sheet mulch-depth-guidance (publishers), source https://extension.psu.edu/mulching-landscape-trees/,
    /// verified 2026-09-25.
    public static let publishers: [Publisher] = [
        Publisher("psu", "Penn State Extension", "https://extension.psu.edu/mulching-landscape-trees/",
                  depthIn: [2.0, 4.0], fineDepthIn: [1.0, 2.0]),
        Publisher("umd", "University of Maryland Extension", "https://extension.umd.edu/resource/mulching-trees-and-shrubs",
                  depthIn: [1.0, 3.0], trunkGapIn: [3.0, 3.0]),
        Publisher("isu", "Iowa State University Extension", "https://yardandgarden.extension.iastate.edu/how-to/using-mulch-garden",
                  depthIn: [2.0, 4.0]),
        Publisher("ucm", "UC Marin Master Gardeners (UC ANR)", "https://ucanr.edu/site/uc-marin-master-gardeners/applying-mulch",
                  trunkGapIn: [6.0, 12.0]),
        Publisher("ncufc", "NCUFC", "https://www.ncufc.org/proper-mulching-for-trees.php",
                  depthIn: [2.0, 4.0], trunkGapIn: [1.0, 2.0],
                  ringRadiusByTreeFt: [TreeRadius(size: "small", ft: 3.0), TreeRadius(size: "medium", ft: 8.0), TreeRadius(size: "large", ft: 12.0)]),
        Publisher("casey", "Casey Trees", "https://caseytrees.org/2024/05/mulching-dos-and-donts/",
                  trunkGapIn: [3.0, 3.0]),
        Publisher("maplegrove", "City of Maple Grove, Minnesota", "https://www.maplegrovemn.gov/DocumentCenter/View/1996/How-to-apply-mulch-around-trees-PDF",
                  trunkGapIn: [3.0, 3.0]),
    ]

    /// How far surfacing must extend from play equipment in all directions, feet (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.extent.all_directions_ft), source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscAllDirectionsFt = 6.0

    /// For to-fro swings, the surfacing front and back as a multiple of the top bar height (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.extent.swing_front_back_multiple_of_top_bar),
    /// source https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscSwingMultiple = 2.0

    /// For tire swings, the feet added to the chain height (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.extent.tire_swing_extra_ft), source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscTireSwingExtraFt = 6.0

    /// The tallest equipment covered by wood mulch or chips in the home handbook, feet (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.loose_fill.wood_mulch_chips_max_equipment_ft),
    /// source https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscWoodMulchMaxEquipmentFt = 8.0

    /// The height below which equipment is "low", feet (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.loose_fill.low_equipment_ft), source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscLowEquipmentFt = 4.0

    /// The maintained loose-fill depth, inches (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.loose_fill.maintained_depth_in), source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscMaintainedDepthIn = 9.0

    /// The initial fill that compresses to the maintained depth, inches (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.loose_fill.initial_fill_in), source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscInitialFillIn = 12.0

    /// The minimum surfacing under low equipment, inches (CPSC 324).
    ///
    /// Data sheet playground-surfacing-cpsc (home_handbook.loose_fill.low_equipment_min_depth_in),
    /// source https://www.cpsc.gov/s3fs-public/324.pdf, verified 2026-09-25.
    public static let cpscLowEquipmentMinDepthIn = 6.0

    /// The fraction by which loose fill compresses at least over time (CPSC 325, public handbook).
    ///
    /// Data sheet playground-surfacing-cpsc (public_handbook.compression_min_fraction), sheet source
    /// https://www.cpsc.gov/s3fs-public/324.pdf, read on https://www.cpsc.gov/s3fs-public/325.pdf,
    /// verified 2026-09-25.
    public static let cpscCompressionMinFraction = 0.25

    /// The CPSC rules in millimetres.
    public struct CPSCRules: Encodable {
        public var allDirectionsMM: Double
        public var swingMultiple: Double
        public var tireExtraMM: Double
        public var maxEquipmentMM: Double
        public var lowEquipmentMM: Double
        public var maintainedMM: Double
        public var lowMaintainedMM: Double
        public var compression: Double
    }

    /// The published maximum depth by texture, mm (Penn State).
    public struct MaxDepth: Encodable {
        public var coarse: Double
        public var fine: Double
    }

    /// The rules of the mulch calculator.
    public struct Rules: Encodable {
        public var cuFtPerCuYd: Double
        public var cpsc: CPSCRules
        public var maxDepth: MaxDepth
    }

    /// Builds the mulch rules: Penn State maximum depths, CPSC home handbook (324)
    /// rules with the public handbook (325) compression, cubic feet per cubic yard.
    public static func newRules() -> Rules {
        let psu = publishers.first { $0.id == "psu" }
        func upper(_ v: [Double]?) -> Double {
            guard let v = v else { return Double.nan }
            return max(v[0], v[1])
        }
        return Rules(
            cuFtPerCuYd: Soil.cubicFeetPerCubicYard,
            cpsc: CPSCRules(
                allDirectionsMM: cpscAllDirectionsFt * foot,
                swingMultiple: cpscSwingMultiple,
                tireExtraMM: cpscTireSwingExtraFt * foot,
                maxEquipmentMM: cpscWoodMulchMaxEquipmentFt * foot,
                lowEquipmentMM: cpscLowEquipmentFt * foot,
                maintainedMM: cpscMaintainedDepthIn * inch,
                lowMaintainedMM: cpscLowEquipmentMinDepthIn * inch,
                compression: cpscCompressionMinFraction
            ),
            maxDepth: MaxDepth(coarse: upper(psu?.depthIn) * inch, fine: upper(psu?.fineDepthIn) * inch)
        )
    }

    /// A published minimum: trunk gap or ring radius.
    public struct Minimum: Encodable {
        public let id: String
        public let publisher: String
        /// The tree size, for ring radii; empty for trunk gaps.
        public let size: String
        public let minMM: Double
    }

    /// The trunk gaps and minimum ring radii.
    public struct RingGuidance: Encodable {
        public let gaps: [Minimum]
        /// By tree size (NCUFC).
        public let radii: [Minimum]
    }

    /// The trunk gaps and minimum ring radii, publisher by publisher; a range
    /// counts by its minimum. Penn State publishes no gap figure and does not appear.
    public static func newRingGuidance() -> RingGuidance {
        var gaps: [Minimum] = []
        var radii: [Minimum] = []
        for p in publishers {
            if let g = p.trunkGapIn {
                gaps.append(Minimum(id: p.id, publisher: p.name, size: "", minMM: min(g[0], g[1]) * inch))
            }
        }
        for p in publishers {
            if let rs = p.ringRadiusByTreeFt {
                for r in rs {
                    radii.append(Minimum(id: p.id, publisher: p.name, size: r.size, minMM: r.ft * foot))
                }
                break
            }
        }
        return RingGuidance(gaps: gaps, radii: radii)
    }

    /// A published minimum and whether the ring meets it.
    public struct Checked: Encodable {
        public let minimum: Minimum
        public let ok: Bool
    }

    /// The result of `checkRing`.
    public struct RingCheck: Encodable {
        public let gaps: [Checked]
        public let radii: [Checked]
    }

    /// Checks a tree ring (radius r and bare gap, mm) against every published
    /// gap and ring radius.
    public static func checkRing(r: Double, gap: Double, guidance: RingGuidance) -> RingCheck {
        RingCheck(
            gaps: guidance.gaps.map { Checked(minimum: $0, ok: gap >= $0.minMM - eps) },
            radii: guidance.radii.map { Checked(minimum: $0, ok: r >= $0.minMM - eps) }
        )
    }

    /// Coarse or fine mulch.
    public enum Texture {
        /// Bark, chips.
        case coarse
        /// Shredded.
        case fine
    }

    /// The kind of a mulch area, lengths in mm.
    public enum Kind {
        /// A rectangular bed, `count` copies (1 to 100).
        case bed(l: Double, w: Double, count: Double)
        /// A ring around a tree: outer radius, trunk diameter, bare gap at the trunk.
        case ring(r: Double, trunk: Double, gap: Double, count: Double)
        /// A known area, mm².
        case knownArea(Double)
        /// A play structure footprint; the depth comes from CPSC.
        case play(l: Double, w: Double, height: Double)
        /// A to-fro swing; the depth and extent come from CPSC.
        case swing(beam: Double, height: Double)
    }

    /// One mulch area.
    public struct Area {
        /// Prefixes error fields.
        public var id: String
        public var kind: Kind
        /// The target depth, mm (garden kinds only).
        public var target: Double
        /// The depth already in place, mm.
        public var existing: Double

        public init(id: String, kind: Kind, target: Double = 0.0, existing: Double = 0.0) {
            self.id = id
            self.kind = kind
            self.target = target
            self.existing = existing
        }
    }

    /// The input of `newPlan`. The default of every field but `areas` is the
    /// calculator default.
    public struct Input {
        /// One to eight areas.
        public var areas: [Area]
        public var texture: Texture
        /// The bag size, 0 for none.
        public var bagSize: Double
        /// Cubic feet or litres.
        public var bagUnit: Soil.BagUnit
        public var bagPrice: Double
        /// Per cubic yard.
        public var bulkPrice: Double
        public var delivery: Double
        /// The sale increment, cu yd, 0 for none.
        public var increment: Double
        /// Percent.
        public var extra: Double
        /// cu ft, 0 for none.
        public var bedVolume: Double
        /// cu ft, 0 for none.
        public var wheelbarrow: Double

        public init(areas: [Area], texture: Texture = .coarse, bagSize: Double = 0.0, bagUnit: Soil.BagUnit = .cubicFeet,
                    bagPrice: Double = 0.0, bulkPrice: Double = 0.0, delivery: Double = 0.0, increment: Double = 0.0,
                    extra: Double = 0.0, bedVolume: Double = 0.0, wheelbarrow: Double = 0.0) {
            self.areas = areas
            self.texture = texture
            self.bagSize = bagSize
            self.bagUnit = bagUnit
            self.bagPrice = bagPrice
            self.bulkPrice = bulkPrice
            self.delivery = delivery
            self.increment = increment
            self.extra = extra
            self.bedVolume = bedVolume
            self.wheelbarrow = wheelbarrow
        }
    }

    /// One area's result, in the order of the input. nil means the value does
    /// not apply to the kind of area.
    public struct AreaPlan: Encodable {
        public var id: String
        public var count: Double
        /// The depth to reach, mm (CPSC initial fill for play and swing).
        public var target: Double
        public var existing: Double
        /// One copy, mm².
        public var areaMM2 = 0.0
        /// One copy, sq ft.
        public var sqFt = 0.0
        public var addedDepth = 0.0
        /// mm³.
        public var volume = 0.0
        public var cuFt = 0.0
        public var cuYd = 0.0
        public var innerMM: Double?
        public var maintainedMM: Double?
        public var initialMM: Double?
        public var extentL: Double?
        public var extentW: Double?
        public var frontMM: Double?
    }

    /// The totals.
    public struct Totals: Encodable {
        public let volume: Double
        public let cuFt: Double
        public let cuYd: Double
        public let orderedCuFt: Double
        public let orderedCuYd: Double
        public let orderedVolume: Double
        public let bulkCuYd: Double
        public let bulkVolume: Double
    }

    /// The buying options. nil means the input it depends on was not entered.
    public struct Buy: Encodable {
        public let bagCuFt: Double?
        public let bags: Double?
        public let bagCost: Double?
        public let bulkCuYd: Double
        public let bulkSurplusCuFt: Double
        public let bulkCost: Double?
        public let cheaper: Soil.Cheaper?
        public let bagPerCuFt: Double?
        public let bulkPerCuFt: Double?
        public let breakEvenCuFt: Double?
    }

    /// The short kind of a warning, as used on the calculator page.
    public enum WarningKind: String, Encodable {
        case overMax = "over-max"
        case alreadyDeep = "already-deep"
        case deepRefill = "deep-refill"
        case increment
    }

    /// A planning warning. The fields that do not belong to its kind are zero.
    public struct Warning: Encodable {
        public var kind: WarningKind
        public var area = ""
        public var maxMM = 0.0
        public var existing = 0.0
        public var target = 0.0
        public var surplusCuFt = 0.0
    }

    /// The result of `newPlan`.
    public struct Plan: Encodable {
        public let areas: [AreaPlan]
        public let totals: Totals
        public let buy: Buy
        /// Truck trips by bed volume, nil without one.
        public let trips: Double?
        /// nil without a wheelbarrow volume.
        public let wheelbarrowLoads: Double?
        public let warnings: [Warning]
    }

    /// Plans mulch: volume per area (CPSC depth and extent for play areas), bags,
    /// bulk, cost and loads.
    public static func newPlan(_ c: Input, rules: Rules) throws -> Plan {
        if c.areas.isEmpty || c.areas.count > 8 {
            throw InputError(message: "Tick one to eight areas.", field: "areas")
        }
        let bagMin: Double
        let bagMax: Double
        let bagUnit: String
        switch c.bagUnit {
        case .cubicFeet:
            bagMin = 0.05
            bagMax = 10.0
            bagUnit = "cu ft"
        case .liters:
            bagMin = 1.0
            bagMax = 300.0
            bagUnit = "liters"
        case .dryQuarts: throw InputError(message: "Choose a bag unit.", field: "bag-unit")
        }
        if c.bagSize != 0.0 {
            try checkRange(c.bagSize, bagMin, bagMax, "Enter a bag size from \(jsNum(bagMin)) to \(jsNum(bagMax)) \(bagUnit), or 0.", "bag")
        }
        try checkRange(c.bagPrice, 0.0, 100000.0, "Enter a bag price from 0 to 100,000 USD.", "bag-price")
        try checkRange(c.bulkPrice, 0.0, 100000.0, "Enter a bulk price from 0 to 100,000 USD.", "bulk-price")
        try checkRange(c.delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
        if c.increment != 0.0 {
            try checkRange(c.increment, 0.1, 10.0, "Enter a sale increment from 0.1 to 10 cu yd, or 0.", "increment")
        }
        try checkRange(c.extra, 0.0, 100.0, "Enter an extra from 0 to 100 %.", "extra")
        if c.bedVolume != 0.0 {
            try checkRange(c.bedVolume, 1.0, 200.0, "Enter a bed volume from 1 to 200 cu ft, or 0.", "bed-volume")
        }
        if c.wheelbarrow != 0.0 {
            try checkRange(c.wheelbarrow, 1.0, 20.0, "Enter a wheelbarrow volume from 1 to 20 cu ft, or 0.", "wheelbarrow")
        }
        let perYd = rules.cuFtPerCuYd
        let p = rules.cpsc
        let maxMM = c.texture == .fine ? rules.maxDepth.fine : rules.maxDepth.coarse
        var warnings: [Warning] = []
        var areas: [AreaPlan] = []
        for a in c.areas {
            func f(_ k: String) -> String { a.id + "-" + k }
            func length(_ v: Double, _ k: String, _ label: String) throws {
                try checkRange(v, lenMin, lenMax, "Enter " + label + lenMsg, f(k))
            }
            func copies(_ n: Double) throws {
                if !isWhole(n) || !(n >= 1.0 && n <= 100.0) {
                    throw InputError(message: "Enter a whole number of copies from 1 to 100.", field: f("count"))
                }
            }
            // Play area: maintained depth by height (6 in under 4 ft, 9 in up to 8 ft, beyond that
            // outside the home handbook); initial fill = maintained / (1 - compression).
            func cpscDepth(_ height: Double) throws -> (maintained: Double, initial: Double) {
                try checkRange(height, lenMin, lenMax, "Enter a height" + lenMsg, f("height"))
                if height > p.maxEquipmentMM + eps {
                    throw InputError(
                        message: "Enter a height up to \(locale(p.maxEquipmentMM / foot, 1)) ft (\(locale(p.maxEquipmentMM, 1)) mm): taller equipment is outside the home handbook for wood mulch.",
                        field: f("height")
                    )
                }
                let maintained = height < p.lowEquipmentMM - eps ? p.lowMaintainedMM : p.maintainedMM
                return (maintained, maintained / (1.0 - p.compression))
            }
            var garden = false
            var plan = AreaPlan(id: a.id, count: 1.0, target: a.target, existing: a.existing)
            switch a.kind {
            case let .bed(l, w, count):
                garden = true
                plan.areaMM2 = try Soil.areaOf(a.id, .rect(l: l, w: w))
                try copies(count)
                plan.count = count
            case let .knownArea(area):
                garden = true
                plan.areaMM2 = try Soil.areaOf(a.id, .knownArea(area))
            case let .ring(r, trunk, gap, count):
                garden = true
                // Trunk and gap at 0: the ring becomes a plain round bed.
                try length(r, "r", "a ring radius")
                try checkRange(trunk, 0.0, lenMax, "Enter a trunk diameter from 0 to 60 m (0 to 196 ft).", f("trunk"))
                try checkRange(gap, 0.0, lenMax, "Enter a bare gap from 0 to 60 m (0 to 196 ft).", f("gap"))
                let inner = trunk / 2.0 + gap
                if inner >= r - eps {
                    throw InputError(message: "The trunk and its bare gap must fit inside the ring radius.", field: f("r"))
                }
                plan.areaMM2 = Double.pi * (r * r - inner * inner)
                try copies(count)
                plan.count = count
                plan.innerMM = inner
            case let .play(l, w, height):
                // CPSC surface: the footprint plus 6 ft on every side.
                let d = try cpscDepth(height)
                try length(l, "l", "a length")
                let extentL = l + 2.0 * p.allDirectionsMM
                try length(w, "w", "a width")
                let extentW = w + 2.0 * p.allDirectionsMM
                plan.areaMM2 = extentL * extentW
                plan.target = d.initial
                plan.maintainedMM = d.maintained
                plan.initialMM = d.initial
                plan.extentL = extentL
                plan.extentW = extentW
            case let .swing(beam, height):
                // Swing: twice the top bar height in front and behind, never under 6 ft all round.
                let d = try cpscDepth(height)
                try length(beam, "beam", "a top bar length")
                let extentL = beam + 2.0 * p.allDirectionsMM
                let front = max(p.swingMultiple * height, p.allDirectionsMM)
                let extentW = 2.0 * front
                plan.areaMM2 = extentL * extentW
                plan.target = d.initial
                plan.maintainedMM = d.maintained
                plan.initialMM = d.initial
                plan.extentL = extentL
                plan.extentW = extentW
                plan.frontMM = front
            }
            if garden {
                try checkRange(a.target, depthMin, depthMax, depthMsg, f("target"))
            }
            try checkRange(a.existing, 0.0, depthMax, existingMsg, f("existing"))
            let target = plan.target
            plan.addedDepth = max(target - a.existing, 0.0)
            plan.volume = plan.areaMM2 * plan.addedDepth * plan.count
            if garden && target > maxMM + eps {
                warnings.append(Warning(kind: .overMax, area: a.id, maxMM: maxMM, target: target))
            }
            if a.existing >= target - eps {
                warnings.append(Warning(kind: .alreadyDeep, area: a.id, existing: a.existing, target: target))
            }
            if garden && a.existing > target + eps {
                warnings.append(Warning(kind: .deepRefill, area: a.id, existing: a.existing, target: target))
            }
            plan.sqFt = plan.areaMM2 / Soil.sqFt
            plan.cuFt = plan.volume / Soil.cuFt
            plan.cuYd = plan.volume / Soil.cuFt / perYd
            areas.append(plan)
        }
        var volume = 0.0
        for a in areas {
            volume += a.volume
        }
        let cuft = volume / Soil.cuFt
        let cuyd = cuft / perYd
        let orderedCuFt = cuft * (1.0 + c.extra / 100.0)
        let orderedCuYd = orderedCuFt / perYd
        // Bags, bulk, break-even and hauling: the soil formulas, by volume only.
        var bc: Double?
        var bags: Double?
        var bagCost: Double?
        if c.bagSize != 0.0 {
            let size = Soil.bagCuFt(c.bagSize, c.bagUnit, dryQuartIn3: Double.nan)
            bc = size
            let n = ceilRel(orderedCuFt / size)
            bags = n
            if c.bagPrice != 0.0 { bagCost = n * c.bagPrice }
        }
        var bulkCuYd = orderedCuYd
        if c.increment != 0.0 {
            bulkCuYd = ceilRel(orderedCuYd / c.increment) * c.increment
        }
        let bulkSurplusCuFt = (bulkCuYd - orderedCuYd) * perYd
        var bulkCost: Double?
        if c.bulkPrice != 0.0 {
            bulkCost = bulkCuYd * c.bulkPrice + c.delivery
        }
        var cheaper: Soil.Cheaper?
        if let bag = bagCost, let bulk = bulkCost {
            cheaper = bag <= bulk ? .bags : .bulk
        }
        var bagPerCuFt: Double?
        var bulkPerCuFt: Double?
        var breakEvenCuFt: Double?
        if let size = bc, size != 0.0, c.bagPrice != 0.0 {
            bagPerCuFt = c.bagPrice / size
        }
        if c.bulkPrice != 0.0 {
            bulkPerCuFt = c.bulkPrice / perYd
        }
        if let bag = bagPerCuFt, let bulk = bulkPerCuFt, bag > bulk {
            breakEvenCuFt = c.delivery / (bag - bulk)
        }
        var trips: Double?
        var wheelbarrowLoads: Double?
        if c.bedVolume != 0.0 { trips = ceilRel(orderedCuFt / c.bedVolume) }
        if c.wheelbarrow != 0.0 { wheelbarrowLoads = ceilRel(orderedCuFt / c.wheelbarrow) }
        if c.increment != 0.0 && bulkSurplusCuFt > eps {
            warnings.append(Warning(kind: .increment, surplusCuFt: bulkSurplusCuFt))
        }
        return Plan(
            areas: areas,
            totals: Totals(volume: volume, cuFt: cuft, cuYd: cuyd, orderedCuFt: orderedCuFt, orderedCuYd: orderedCuYd,
                           orderedVolume: orderedCuFt * Soil.cuFt, bulkCuYd: bulkCuYd, bulkVolume: bulkCuYd * perYd * Soil.cuFt),
            buy: Buy(bagCuFt: bc, bags: bags, bagCost: bagCost, bulkCuYd: bulkCuYd, bulkSurplusCuFt: bulkSurplusCuFt,
                     bulkCost: bulkCost, cheaper: cheaper, bagPerCuFt: bagPerCuFt, bulkPerCuFt: bulkPerCuFt,
                     breakEvenCuFt: breakEvenCuFt),
            trips: trips,
            wheelbarrowLoads: wheelbarrowLoads,
            warnings: warnings
        )
    }

    /// The coverage of one bag size.
    public struct BagCoverage: Encodable {
        /// The bag volume, cu ft.
        public let cuFt: Double
        /// The square feet covered at each depth asked.
        public let sqFt: [Double]
        public let bagsPerCuYd: Double
    }

    /// The square feet covered by one bag at each depth (inches), and the bags
    /// per cubic yard.
    public static func coverage(bagCuFts: [Double], depthsIn: [Double], rules: Rules) -> [BagCoverage] {
        let inPerFt = foot / inch
        return bagCuFts.map { cuft in
            BagCoverage(cuFt: cuft, sqFt: depthsIn.map { cuft * inPerFt / $0 }, bagsPerCuYd: rules.cuFtPerCuYd / cuft)
        }
    }
}
