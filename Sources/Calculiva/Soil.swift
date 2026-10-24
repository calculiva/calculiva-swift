import Foundation

/// Topsoil and fill dirt by area: volume, bags, bulk, weight and hauling.
///
/// Lengths are millimetres; weights are pounds and short tons; sale volumes are
/// cubic feet and cubic yards. The material weights and the wheelbarrow volume
/// are entries of the user. The results are planning quantities: the supplier's
/// quote and the vehicle's rated payload govern.
///
/// Calculator page: https://calculiva.com/landscaping/soil-calculator/
public enum Soil {
    /// One square foot in mm².
    public static let sqFt = foot * foot
    /// One cubic foot in mm³.
    public static let cuFt = sqFt * foot
    static let cuIn = inch * inch * inch
    static let litre = 1e6
    static let sqM = 1e6

    /// The number of pounds in a short ton.
    ///
    /// Data sheet soil-weights-and-sale-units (physical_basis.pounds_per_short_ton),
    /// source https://www.nist.gov/document/2026-hb-130-section-iv-b, verified 2026-09-25.
    public static let poundsPerShortTon = 2000.0

    /// The number of cubic feet in a cubic yard.
    ///
    /// Data sheet soil-weights-and-sale-units (physical_basis.cubic_feet_per_cubic_yard),
    /// source https://www.nist.gov/document/2026-hb-130-section-iv-b, verified 2026-09-25.
    public static let cubicFeetPerCubicYard = 27.0

    /// The number of cubic inches in a U.S. dry quart (1/32 of the 2,150.42 in³ bushel).
    ///
    /// Data sheet soil-weights-and-sale-units (sale_units.dry_measure.dry_quart_in3),
    /// source https://www.nist.gov/document/2026-hb-130-section-iv-b
    /// (NIST Handbook 130, IV-A: https://www.nist.gov/document/2026-hb-130-section-iv), verified 2026-09-25.
    public static let dryQuartIn3 = 67.200625

    /// The loose and bank weight of a material, in pounds per cubic yard, and its
    /// load factor, as entered by the user.
    public struct Weight: Encodable, Equatable {
        public var id: String
        public var label: String
        public var loose: Double
        public var bank: Double
        public var loadFactor: Double

        public init(id: String, label: String, loose: Double, bank: Double, loadFactor: Double) {
            self.id = id
            self.label = label
            self.loose = loose
            self.bank = bank
            self.loadFactor = loadFactor
        }
    }

    /// The rules of the soil calculator.
    public struct Rules: Encodable {
        public var poundsPerTon: Double
        public var cuFtPerCuYd: Double
        public var dryQuartIn3: Double
        /// The material weights, entered by the user (none by default).
        public var weights: [Weight]

        /// Builds the soil rules from the sourced constants, with the material
        /// weights given by the user.
        public init(weights: [Weight] = []) {
            poundsPerTon = Soil.poundsPerShortTon
            cuFtPerCuYd = Soil.cubicFeetPerCubicYard
            dryQuartIn3 = Soil.dryQuartIn3
            self.weights = weights
        }

        func weight(_ id: String) -> Weight? {
            weights.first { $0.id == id }
        }
    }

    /// The shape of an area. Lengths are mm; a known area is already in mm².
    public enum Shape {
        case rect(l: Double, w: Double)
        case circle(d: Double)
        case triangle(b: Double, h: Double)
        case knownArea(Double)
    }

    /// The area of a shape in mm². id prefixes the field name of any error ("a1-l").
    public static func areaOf(_ id: String, _ shape: Shape) throws -> Double {
        func f(_ k: String) -> String { id + "-" + k }
        func length(_ v: Double, _ k: String, _ label: String) throws {
            try checkRange(v, lenMin, lenMax, "Enter " + label + lenMsg, f(k))
        }
        switch shape {
        case let .rect(l, w):
            try length(l, "l", "a length")
            try length(w, "w", "a width")
            return l * w
        case let .circle(d):
            try length(d, "d", "a diameter")
            return Double.pi * d * d / 4.0
        case let .triangle(b, h):
            try length(b, "b", "a base")
            try length(h, "h", "a height")
            return b * h / 2.0
        case let .knownArea(area):
            try checkRange(area, 0.1 * sqM, 10000.0 * sqM, "Enter an area from 0.1 to 10,000 m² (about 1.1 to 107,639 sq ft).", f("area"))
            return area
        }
    }

    /// The unit in which a bag's volume is printed.
    public enum BagUnit: String, Encodable {
        case cubicFeet = "cuFt"
        case dryQuarts
        case liters

        var bounds: (lo: Double, hi: Double, name: String) {
            switch self {
            case .dryQuarts: return (1.0, 400.0, "dry quarts")
            case .liters: return (1.0, 300.0, "liters")
            case .cubicFeet: return (0.05, 10.0, "cu ft")
            }
        }
    }

    /// The volume of a bag in cubic feet.
    public static func bagCuFt(_ size: Double, _ unit: BagUnit, dryQuartIn3: Double) -> Double {
        switch unit {
        case .dryQuarts: return size * dryQuartIn3 * cuIn / cuFt
        case .liters: return size * litre / cuFt
        case .cubicFeet: return size
        }
    }

    /// Topsoil or fill dirt.
    public enum Material: String, Encodable {
        case topsoil
        case fill
    }

    /// One area to fill.
    public struct Area {
        public var id: String
        public var shape: Shape
        /// The depth in mm (3 to 1,500).
        public var depth: Double
        /// The number of identical copies (1 to 100).
        public var count: Double
        public var material: Material

        public init(id: String, shape: Shape, depth: Double, count: Double = 1.0, material: Material = .topsoil) {
            self.id = id
            self.shape = shape
            self.depth = depth
            self.count = count
            self.material = material
        }
    }

    /// The bag and bulk details of one material.
    public struct MaterialInput {
        /// The bag size, 0 for no bags.
        public var bagSize: Double
        public var bagUnit: BagUnit
        /// The price of one bag, 0 if unknown.
        public var bagPrice: Double
        /// The bulk price per cubic yard or per ton, 0 if unknown.
        public var bulkPrice: Double
        /// The id of a row of `Rules.weights`.
        public var weight: String

        public init(bagSize: Double = 0.0, bagUnit: BagUnit = .cubicFeet, bagPrice: Double = 0.0, bulkPrice: Double = 0.0, weight: String) {
            self.bagSize = bagSize
            self.bagUnit = bagUnit
            self.bagPrice = bagPrice
            self.bulkPrice = bulkPrice
            self.weight = weight
        }
    }

    /// How the bulk price is quoted.
    public enum BulkBy {
        case yard
        case ton
    }

    /// The input of `newPlan`. The default of every field but `areas` is the
    /// calculator default.
    public struct Input {
        public var areas: [Area]
        public var topsoil: MaterialInput?
        public var fill: MaterialInput?
        public var bulkBy: BulkBy
        public var delivery: Double
        /// The supplier's sale increment in cubic yards, 0 for none.
        public var increment: Double
        /// The extra in percent.
        public var extra: Double
        /// The vehicle payload in pounds, 0 for none.
        public var payload: Double
        /// The bed volume in cubic feet, 0 for none.
        public var bedVolume: Double
        /// The wheelbarrow volume in cubic feet, 0 for none.
        public var wheelbarrow: Double

        public init(areas: [Area], topsoil: MaterialInput? = nil, fill: MaterialInput? = nil, bulkBy: BulkBy = .yard,
                    delivery: Double = 0.0, increment: Double = 0.0, extra: Double = 0.0, payload: Double = 0.0,
                    bedVolume: Double = 0.0, wheelbarrow: Double = 0.0) {
            self.areas = areas
            self.topsoil = topsoil
            self.fill = fill
            self.bulkBy = bulkBy
            self.delivery = delivery
            self.increment = increment
            self.extra = extra
            self.payload = payload
            self.bedVolume = bedVolume
            self.wheelbarrow = wheelbarrow
        }
    }

    /// One area's volume.
    public struct AreaPlan: Encodable {
        public let id: String
        public let material: Material
        public let count: Double
        public let depth: Double
        public let areaMM2: Double
        public let sqFt: Double
        public let volume: Double
        public let cuFt: Double
        public let cuYd: Double
    }

    /// Which option is cheaper (bags also on a tie).
    public enum Cheaper: String, Encodable {
        case bags
        case bulk
    }

    /// Which limit sets the number of trips.
    public enum Binding: String, Encodable {
        case weight
        case volume
        case both
    }

    /// The order, cost and hauling for one material. nil means the value is
    /// absent: the input it depends on was not entered.
    public struct MaterialPlan: Encodable {
        public let id: Material
        public let weight: Weight
        public let volume: Double
        public let cuFt: Double
        public let cuYd: Double
        public let orderedCuFt: Double
        public let orderedCuYd: Double
        public let orderedVolume: Double
        public let bagCuFt: Double?
        public let bags: Double?
        public let bagCost: Double?
        public let bulkCuYd: Double
        public let bulkVolume: Double
        public let bulkSurplusCuFt: Double
        public let looseLb: Double
        public let bulkTons: Double
        public let bulkCost: Double?
        public let cheaper: Cheaper?
        public let bagPerCuFt: Double?
        public let bulkPerCuFt: Double?
        public let breakEvenCuFt: Double?
        public let orderedLooseLb: Double
        public let bankLb: Double
        public let settledCuFt: Double
        public let tripsByWeight: Double?
        public let tripsByVolume: Double?
        public let trips: Double?
        public let binding: Binding?
        public let wheelbarrowLoads: Double?
        public let lbPerLoad: Double?
    }

    /// The totals over the materials.
    public struct Totals: Encodable {
        public var volume = 0.0
        public var cuFt = 0.0
        public var cuYd = 0.0
        public var orderedCuFt = 0.0
        public var orderedCuYd = 0.0
        public var orderedVolume = 0.0
        public var bulkCuYd = 0.0
        public var looseLb = 0.0
        public var trips: Double?
        public var wheelbarrowLoads: Double?
    }

    /// The bulk increment adds volume over the order.
    public struct IncrementWarning: Encodable {
        public let material: Material
        public let surplusCuFt: Double
    }

    /// The result of `newPlan`.
    public struct Plan: Encodable {
        public let areas: [AreaPlan]
        /// The materials in use, topsoil first.
        public let materials: [MaterialPlan]
        public let totals: Totals
        public let warnings: [IncrementWarning]
    }

    /// Plans topsoil and fill: volume per area, bags, bulk, cost, weight and
    /// trips per material.
    public static func newPlan(_ c: Input, rules: Rules) throws -> Plan {
        if c.areas.isEmpty || c.areas.count > 8 {
            throw InputError(message: "Enter one to eight areas.", field: "areas")
        }
        try checkRange(c.delivery, 0.0, 10000.0, "Enter a delivery charge from 0 to 10,000 USD.", "delivery")
        if c.increment != 0.0 {
            try checkRange(c.increment, 0.1, 10.0, "Enter a sale increment from 0.1 to 10 cu yd, or 0.", "increment")
        }
        try checkRange(c.extra, 0.0, 100.0, "Enter an extra from 0 to 100 %.", "extra")
        if c.payload != 0.0 {
            try checkRange(c.payload, 100.0, 20000.0, "Enter a payload from 100 to 20,000 lb, or 0.", "payload")
        }
        if c.bedVolume != 0.0 {
            try checkRange(c.bedVolume, 1.0, 200.0, "Enter a bed volume from 1 to 200 cu ft, or 0.", "bed-volume")
        }
        if c.wheelbarrow != 0.0 {
            try checkRange(c.wheelbarrow, 1.0, 20.0, "Enter a wheelbarrow volume from 1 to 20 cu ft, or 0.", "wheelbarrow")
        }
        let perYd = rules.cuFtPerCuYd
        let lbTon = rules.poundsPerTon
        var areas: [AreaPlan] = []
        for a in c.areas {
            let areaMM2 = try areaOf(a.id, a.shape)
            try checkRange(a.depth, 3.0, 1500.0, "Enter a depth from 1/8 in to 59 in (3 to 1,500 mm).", a.id + "-depth")
            if !isWhole(a.count) || a.count < 1.0 || a.count > 100.0 {
                throw InputError(message: "Enter a whole number of copies from 1 to 100.", field: a.id + "-count")
            }
            let volume = areaMM2 * a.depth * a.count
            areas.append(AreaPlan(id: a.id, material: a.material, count: a.count, depth: a.depth, areaMM2: areaMM2,
                                  sqFt: areaMM2 / sqFt, volume: volume, cuFt: volume / cuFt, cuYd: volume / cuFt / perYd))
        }
        var materials: [MaterialPlan] = []
        for (id, input) in [(Material.topsoil, c.topsoil), (Material.fill, c.fill)] {
            if !areas.contains(where: { $0.material == id }) { continue }
            func f(_ k: String) -> String { id.rawValue + "-" + k }
            guard let m = input else {
                throw InputError(message: "Enter the bag and bulk details of this material.", field: f("bag"))
            }
            if m.bagSize != 0.0 {
                let b = m.bagUnit.bounds
                try checkRange(m.bagSize, b.lo, b.hi, "Enter a bag size from \(jsNum(b.lo)) to \(jsNum(b.hi)) \(b.name), or 0.", f("bag"))
            }
            try checkRange(m.bagPrice, 0.0, 100000.0, "Enter a bag price from 0 to 100,000 USD.", f("bag-price"))
            try checkRange(m.bulkPrice, 0.0, 100000.0, "Enter a bulk price from 0 to 100,000 USD.", f("bulk-price"))
            guard let w = rules.weight(m.weight) else {
                throw InputError(message: "Choose a material weight.", field: f("weight"))
            }
            var volume = 0.0
            for a in areas where a.material == id {
                volume += a.volume
            }
            let cuft = volume / cuFt
            let cuyd = cuft / perYd
            let orderedCuFt = cuft * (1.0 + c.extra / 100.0)
            let orderedCuYd = orderedCuFt / perYd
            let orderedVolume = orderedCuFt * cuFt
            // Bags are whole; bulk rounds up to the supplier's sale increment, never down.
            var bc: Double?
            var bags: Double?
            var bagCost: Double?
            if m.bagSize != 0.0 {
                let size = bagCuFt(m.bagSize, m.bagUnit, dryQuartIn3: rules.dryQuartIn3)
                bc = size
                let n = ceilRel(orderedCuFt / size)
                bags = n
                if m.bagPrice != 0.0 { bagCost = n * m.bagPrice }
            }
            var bulkCuYd = orderedCuYd
            if c.increment != 0.0 {
                bulkCuYd = ceilRel(orderedCuYd / c.increment) * c.increment
            }
            let bulkSurplusCuFt = (bulkCuYd - orderedCuYd) * perYd
            let looseLb = bulkCuYd * w.loose
            let bulkTons = looseLb / lbTon
            var bulkCost: Double?
            if m.bulkPrice != 0.0 {
                bulkCost = c.bulkBy == .yard ? bulkCuYd * m.bulkPrice + c.delivery : bulkTons * m.bulkPrice + c.delivery
            }
            var cheaper: Cheaper?
            if let bag = bagCost, let bulk = bulkCost {
                cheaper = bag <= bulk ? .bags : .bulk
            }
            // Continuous break-even: the volume where bulk with delivery equals bags, unrounded.
            var bagPerCuFt: Double?
            var bulkPerCuFt: Double?
            var breakEvenCuFt: Double?
            if let size = bc, size != 0.0, m.bagPrice != 0.0 {
                bagPerCuFt = m.bagPrice / size
            }
            if m.bulkPrice != 0.0 {
                bulkPerCuFt = c.bulkBy == .yard ? m.bulkPrice / perYd : m.bulkPrice * w.loose / lbTon / perYd
            }
            if let bag = bagPerCuFt, let bulk = bulkPerCuFt, bag > bulk {
                breakEvenCuFt = c.delivery / (bag - bulk)
            }
            // Hauling: weight is read on the unrounded order (what one loads oneself).
            let orderedLooseLb = orderedCuYd * w.loose
            let bankLb = orderedCuYd * w.bank
            let settledCuFt = orderedCuFt * w.loadFactor
            var tripsByWeight: Double?
            var tripsByVolume: Double?
            if c.payload != 0.0 { tripsByWeight = ceilRel(orderedLooseLb / c.payload) }
            if c.bedVolume != 0.0 { tripsByVolume = ceilRel(orderedCuFt / c.bedVolume) }
            var trips: Double?
            var binding: Binding?
            switch (tripsByWeight, tripsByVolume) {
            case let (a?, b?):
                trips = max(a, b)
                binding = a > b ? .weight : (b > a ? .volume : .both)
            case let (a?, nil):
                trips = a
                binding = .weight
            case let (nil, b?):
                trips = b
                binding = .volume
            case (nil, nil):
                break
            }
            var wheelbarrowLoads: Double?
            var lbPerLoad: Double?
            if c.wheelbarrow != 0.0 {
                wheelbarrowLoads = ceilRel(orderedCuFt / c.wheelbarrow)
                lbPerLoad = c.wheelbarrow / perYd * w.loose
            }
            materials.append(MaterialPlan(
                id: id, weight: w, volume: volume, cuFt: cuft, cuYd: cuyd,
                orderedCuFt: orderedCuFt, orderedCuYd: orderedCuYd, orderedVolume: orderedVolume,
                bagCuFt: bc, bags: bags, bagCost: bagCost,
                bulkCuYd: bulkCuYd, bulkVolume: bulkCuYd * perYd * cuFt, bulkSurplusCuFt: bulkSurplusCuFt,
                looseLb: looseLb, bulkTons: bulkTons, bulkCost: bulkCost, cheaper: cheaper,
                bagPerCuFt: bagPerCuFt, bulkPerCuFt: bulkPerCuFt, breakEvenCuFt: breakEvenCuFt,
                orderedLooseLb: orderedLooseLb, bankLb: bankLb, settledCuFt: settledCuFt,
                tripsByWeight: tripsByWeight, tripsByVolume: tripsByVolume, trips: trips, binding: binding,
                wheelbarrowLoads: wheelbarrowLoads, lbPerLoad: lbPerLoad
            ))
        }
        var totals = Totals()
        var withTrips = false
        var trips = 0.0
        var loads = 0.0
        for m in materials {
            totals.volume += m.volume
            totals.cuFt += m.cuFt
            totals.cuYd += m.cuYd
            totals.orderedCuFt += m.orderedCuFt
            totals.orderedCuYd += m.orderedCuYd
            totals.orderedVolume += m.orderedVolume
            totals.bulkCuYd += m.bulkCuYd
            totals.looseLb += m.looseLb
            if let t = m.trips {
                withTrips = true
                trips += t
            }
            if let l = m.wheelbarrowLoads { loads += l }
        }
        if withTrips { totals.trips = trips }
        if c.wheelbarrow != 0.0 { totals.wheelbarrowLoads = loads }
        var warnings: [IncrementWarning] = []
        for m in materials where c.increment != 0.0 && m.bulkSurplusCuFt > eps {
            warnings.append(IncrementWarning(material: m.id, surplusCuFt: m.bulkSurplusCuFt))
        }
        return Plan(areas: areas, materials: materials, totals: totals, warnings: warnings)
    }

    /// The area covered at one depth.
    public struct CoverageRow: Encodable {
        public let inches: Double
        public let sqFtPerCuYd: Double
        /// At the loose weight.
        public let sqFtPerTon: Double
        public let sqFtPerCuFt: Double
    }

    /// The area covered at each depth: per cubic yard, per ton (loose weight of
    /// weightID) and per cubic foot.
    public static func coverage(depthsIn: [Double], rules: Rules, weightID: String) throws -> [CoverageRow] {
        guard let w = rules.weight(weightID) else {
            throw InputError(message: "Choose a material weight.", field: "weight")
        }
        let inPerFt = foot / inch
        return depthsIn.map { inches in
            let sqftPerCuYd = rules.cuFtPerCuYd * inPerFt / inches
            return CoverageRow(inches: inches, sqFtPerCuYd: sqftPerCuYd,
                               sqFtPerTon: sqftPerCuYd * rules.poundsPerTon / w.loose, sqFtPerCuFt: inPerFt / inches)
        }
    }
}
