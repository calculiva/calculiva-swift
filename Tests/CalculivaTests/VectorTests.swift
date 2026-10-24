import Calculiva
import Foundation
import XCTest

/// A JSON value, decoded with JSONDecoder on every platform.
enum JSON: Decodable, Equatable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([JSON])
    case object([String: JSON])

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() {
            self = .null
        } else if let b = try? c.decode(Bool.self) {
            self = .bool(b)
        } else if let n = try? c.decode(Double.self) {
            self = .number(n)
        } else if let s = try? c.decode(String.self) {
            self = .string(s)
        } else if let a = try? c.decode([JSON].self) {
            self = .array(a)
        } else {
            self = .object(try c.decode([String: JSON].self))
        }
    }

    subscript(key: String) -> JSON {
        if case let .object(o) = self { return o[key] ?? .null }
        return .null
    }

    var num: Double {
        if case let .number(n) = self { return n }
        return 0.0
    }

    var str: String {
        if case let .string(s) = self { return s }
        return ""
    }

    var list: [JSON] {
        if case let .array(a) = self { return a }
        return []
    }

    var nums: [Double] { list.map { $0.num } }

    var isNull: Bool { self == .null }
}

func encodeJSON<T: Encodable>(_ value: T) throws -> JSON {
    try JSONDecoder().decode(JSON.self, from: JSONEncoder().encode(value))
}

struct Rows<T: Encodable>: Encodable {
    let rows: [T]
}

/// Appends every difference between want and got (a missing key equals null).
func jsonDiff(_ want: JSON, _ got: JSON, _ path: String, _ rel: Double, _ abs0: Double, _ out: inout [String]) {
    switch (want, got) {
    case let (.number(a), .number(b)):
        if !(abs(a - b) <= max(abs0, rel * max(abs(a), abs(b)))) {
            out.append("\(path): want \(a), got \(b)")
        }
    case let (.object(a), .object(b)):
        for k in Set(a.keys).union(b.keys).sorted() {
            jsonDiff(a[k] ?? .null, b[k] ?? .null, path + "." + k, rel, abs0, &out)
        }
    case let (.array(a), .array(b)):
        if a.count != b.count {
            out.append("\(path): want \(a.count) items, got \(b.count)")
            return
        }
        for i in a.indices {
            jsonDiff(a[i], b[i], "\(path)[\(i)]", rel, abs0, &out)
        }
    default:
        if want != got {
            out.append("\(path): want \(want), got \(got)")
        }
    }
}

// ---- inputs ----

func bagUnit(_ v: JSON) -> Soil.BagUnit {
    switch v.str {
    case "dryQuarts": return .dryQuarts
    case "liters": return .liters
    default: return .cubicFeet
    }
}

func soilShape(_ s: JSON) -> Soil.Shape {
    switch s["type"].str {
    case "rect": return .rect(l: s["l"].num, w: s["w"].num)
    case "circle": return .circle(d: s["d"].num)
    case "triangle": return .triangle(b: s["b"].num, h: s["h"].num)
    default: return .knownArea(s["area"].num)
    }
}

func soilRules(_ v: JSON) -> Soil.Rules {
    Soil.Rules(weights: v["weights"].list.map {
        Soil.Weight(id: $0["id"].str, label: $0["label"].str, loose: $0["loose"].num, bank: $0["bank"].num, loadFactor: $0["loadFactor"].num)
    })
}

func soilMaterial(_ m: JSON) -> Soil.MaterialInput? {
    if m.isNull { return nil }
    return Soil.MaterialInput(bagSize: m["bagSize"].num, bagUnit: bagUnit(m["bagUnit"]), bagPrice: m["bagPrice"].num,
                              bulkPrice: m["bulkPrice"].num, weight: m["weight"].str)
}

func soilInput(_ p: JSON) -> Soil.Input {
    Soil.Input(
        areas: p["areas"].list.map {
            Soil.Area(id: $0["id"].str, shape: soilShape($0["shape"]), depth: $0["depth"].num, count: $0["count"].num,
                      material: $0["material"].str == "fill" ? .fill : .topsoil)
        },
        topsoil: soilMaterial(p["topsoil"]), fill: soilMaterial(p["fill"]),
        bulkBy: p["bulkBy"].str == "ton" ? .ton : .yard,
        delivery: p["delivery"].num, increment: p["increment"].num, extra: p["extra"].num, payload: p["payload"].num,
        bedVolume: p["bedVolume"].num, wheelbarrow: p["wheelbarrow"].num
    )
}

func mulchKind(_ k: JSON) -> Mulch.Kind {
    switch k["type"].str {
    case "bed": return .bed(l: k["l"].num, w: k["w"].num, count: k["count"].num)
    case "ring": return .ring(r: k["r"].num, trunk: k["trunk"].num, gap: k["gap"].num, count: k["count"].num)
    case "play": return .play(l: k["l"].num, w: k["w"].num, height: k["height"].num)
    case "swing": return .swing(beam: k["beam"].num, height: k["height"].num)
    default: return .knownArea(k["area"].num)
    }
}

func mulchInput(_ p: JSON) -> Mulch.Input {
    Mulch.Input(
        areas: p["areas"].list.map {
            Mulch.Area(id: $0["id"].str, kind: mulchKind($0["kind"]), target: $0["target"].num, existing: $0["existing"].num)
        },
        texture: p["texture"].str == "fine" ? .fine : .coarse,
        bagSize: p["bagSize"].num, bagUnit: bagUnit(p["bagUnit"]), bagPrice: p["bagPrice"].num,
        bulkPrice: p["bulkPrice"].num, delivery: p["delivery"].num, increment: p["increment"].num,
        extra: p["extra"].num, bedVolume: p["bedVolume"].num, wheelbarrow: p["wheelbarrow"].num
    )
}

func sodShape(_ s: JSON) -> Sod.Shape {
    switch s["type"].str {
    case "rect": return .rect(l: s["l"].num, w: s["w"].num, count: s["count"].num)
    case "circle": return .circle(r: s["r"].num, count: s["count"].num)
    case "triangle": return .triangle(b: s["b"].num, h: s["h"].num, count: s["count"].num)
    default: return .knownArea(s["area"].num)
    }
}

func sodAreas(_ v: JSON) -> [Sod.Area] {
    v["areas"].list.map { Sod.Area(id: $0["id"].str, shape: sodShape($0["shape"])) }
}

func sodRules(_ r: JSON) -> Sod.Rules {
    var rules = Sod.newRules()
    rules.allowance = r["allowance"].num
    rules.allowanceComplex = r["allowanceComplex"].num
    return rules
}

func sodInput(_ p: JSON, _ rules: Sod.Rules) -> Sod.Input {
    var c = Sod.newInput(areas: sodAreas(p), rules: rules)
    c.format = p["format"].str
    c.pieceW = p["pieceW"].num
    c.pieceL = p["pieceL"].num
    c.palletMode = p["palletMode"].str == "sqFt" ? .bySqFt : .byPieces
    c.palletPieces = p["palletPieces"].num
    c.palletSqFt = p["palletSqFt"].num
    c.allowance = p["allowance"].num
    c.spare = p["spare"].num
    c.method = p["method"].str == "plugs" ? .plugs : .solid
    c.species = p["species"].str
    c.spacing = p["spacing"].num
    c.plugSize = p["plugSize"].num
    c.topsoil = p["topsoil"].num
    c.organic = Sod.Organic(rawValue: p["organic"].str) ?? .layer
    c.organicIn = p["organicIn"].num
    c.organicRate = p["organicRate"].num
    c.priceMode = Sod.PriceMode(rawValue: p["priceMode"].str) ?? .perPallet
    c.price = p["price"].num
    c.delivery = p["delivery"].num
    c.payload = p["payload"].num
    return c
}

struct Units: Encodable {
    let inch: Double
    let foot: Double
}

struct SoilConstants: Encodable {
    let poundsPerShortTon = Soil.poundsPerShortTon
    let cubicFeetPerCubicYard = Soil.cubicFeetPerCubicYard
    let dryQuartIn3 = Soil.dryQuartIn3
    let sqFt = Soil.sqFt
    let cuFt = Soil.cuFt
}

struct MulchConstants: Encodable {
    let cpscAllDirectionsFt = Mulch.cpscAllDirectionsFt
    let cpscSwingMultiple = Mulch.cpscSwingMultiple
    let cpscTireSwingExtraFt = Mulch.cpscTireSwingExtraFt
    let cpscWoodMulchMaxEquipmentFt = Mulch.cpscWoodMulchMaxEquipmentFt
    let cpscLowEquipmentFt = Mulch.cpscLowEquipmentFt
    let cpscMaintainedDepthIn = Mulch.cpscMaintainedDepthIn
    let cpscInitialFillIn = Mulch.cpscInitialFillIn
    let cpscLowEquipmentMinDepthIn = Mulch.cpscLowEquipmentMinDepthIn
    let cpscCompressionMinFraction = Mulch.cpscCompressionMinFraction
    let publishers = Mulch.publishers
}

struct SodConstants: Encodable {
    let sqFt = Sod.sqFt
    let sqYd = Sod.sqYd
    let cuFt = Sod.cuFt
    let cuYd = Sod.cuYd
    let formats = Sod.formats
    let slabPiecesPerStatedPallet = Sod.slabPiecesPerStatedPallet
    let palletWeightLb = Sod.palletWeightLb
    let psuTopsoilSettledIn = Sod.psuTopsoilSettledIn
    let psuOrganicLayerIn = Sod.psuOrganicLayerIn
    let psuOrganicLayerMaxSinglePassIn = Sod.psuOrganicLayerMaxSinglePassIn
    let ncsuOrganicCuYdPer1000SqFt = Sod.ncsuOrganicCuYdPer1000SqFt
    let ifasTable3 = Sod.ifasTable3
    let twoInchPlugsPerSqYd = Sod.twoInchPlugsPerSqYd
    let plugSizesIn = Sod.plugSizesIn
}

struct AreaOut: Encodable {
    let areaMM2: Double
}

struct CuFtOut: Encodable {
    let cuFt: Double
}

/// Runs one vector on the Swift port and returns its canonical JSON output.
func runVector(_ fn: String, _ i: JSON) throws -> JSON {
    switch fn {
    case "units": return try encodeJSON(Units(inch: inch, foot: foot))
    case "soil.constants": return try encodeJSON(SoilConstants())
    case "soil.newRules": return try encodeJSON(soilRules(i))
    case "soil.areaOf": return try encodeJSON(AreaOut(areaMM2: try Soil.areaOf(i["id"].str, soilShape(i["shape"]))))
    case "soil.bagCuFt": return try encodeJSON(CuFtOut(cuFt: Soil.bagCuFt(i["size"].num, bagUnit(i["unit"]), dryQuartIn3: i["dryQuartIn3"].num)))
    case "soil.newPlan": return try encodeJSON(try Soil.newPlan(soilInput(i["plan"]), rules: soilRules(i)))
    case "soil.coverage":
        return try encodeJSON(Rows(rows: try Soil.coverage(depthsIn: i["depthsIn"].nums, rules: soilRules(i), weightID: i["weightId"].str)))
    case "mulch.constants": return try encodeJSON(MulchConstants())
    case "mulch.newRules": return try encodeJSON(Mulch.newRules())
    case "mulch.newRingGuidance": return try encodeJSON(Mulch.newRingGuidance())
    case "mulch.checkRing": return try encodeJSON(Mulch.checkRing(r: i["r"].num, gap: i["gap"].num, guidance: Mulch.newRingGuidance()))
    case "mulch.newPlan": return try encodeJSON(try Mulch.newPlan(mulchInput(i["plan"]), rules: Mulch.newRules()))
    case "mulch.coverage":
        return try encodeJSON(Rows(rows: Mulch.coverage(bagCuFts: i["bagCuFts"].nums, depthsIn: i["depthsIn"].nums, rules: Mulch.newRules())))
    case "sod.constants": return try encodeJSON(SodConstants())
    case "sod.newRules": return try encodeJSON(Sod.newRules())
    case "sod.layRect": return try encodeJSON(try Sod.layRect(l: i["l"].num, w: i["w"].num, pieceW: i["pieceW"].num, pieceL: i["pieceL"].num))
    case "sod.newInput": return try encodeJSON(Sod.newInput(areas: sodAreas(i), rules: sodRules(i["rules"])))
    case "sod.newPlan":
        let rules = sodRules(i["rules"])
        return try encodeJSON(try Sod.newPlan(sodInput(i["plan"], rules), rules: rules))
    case "sod.formatTable":
        return try encodeJSON(Rows(rows: Sod.formatTable(rules: Sod.newRules(), soldAs: i["soldAs"].nums, sqft: i["sqft"].num)))
    default:
        throw InputError(message: "unknown function " + fn, field: "fn")
    }
}

final class VectorTests: XCTestCase {
    func loadVectors() throws -> JSON {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("vectors.json")
        return try JSONDecoder().decode(JSON.self, from: Data(contentsOf: url))
    }

    func testVersionMatchesVectors() throws {
        XCTAssertEqual(try loadVectors()["version"].str, "v" + calculivaVersion)
    }

    func testVectors() throws {
        let doc = try loadVectors()
        let rel = doc["tolerance"]["rel"].num
        let abs0 = doc["tolerance"]["abs"].num
        let vectors = doc["vectors"].list
        XCTAssertGreaterThan(vectors.count, 100)
        var passed = 0
        for v in vectors {
            let id = v["id"].str
            var diffs: [String] = []
            do {
                let got = try runVector(v["fn"].str, v["input"])
                if v["error"].isNull {
                    jsonDiff(v["output"], got, "output", rel, abs0, &diffs)
                } else {
                    diffs.append("want error \(v["error"]), got a result")
                }
            } catch let e as InputError {
                if v["error"].isNull {
                    diffs.append("unexpected error \(e)")
                } else {
                    let got = JSON.object(["field": .string(e.field), "message": .string(e.message)])
                    jsonDiff(v["error"], got, "error", rel, abs0, &diffs)
                }
            }
            if diffs.isEmpty {
                passed += 1
            } else {
                XCTFail("\(id): " + diffs.prefix(5).joined(separator: "; "))
            }
        }
        XCTAssertEqual(passed, vectors.count)
    }

    func testExample() throws {
        // Two 40 x 3 ft beds topped up from 1 in to 3 in, bought in 2 cu ft bags.
        let bed = Mulch.Area(id: "front-bed", kind: .bed(l: 40 * foot, w: 3 * foot, count: 2), target: 3 * inch, existing: 1 * inch)
        let plan = try Mulch.newPlan(Mulch.Input(areas: [bed], bagSize: 2), rules: Mulch.newRules())
        XCTAssertEqual(plan.totals.cuFt, 40.0, accuracy: 1e-9)
        XCTAssertEqual(plan.buy.bags, 20.0)
    }
}
