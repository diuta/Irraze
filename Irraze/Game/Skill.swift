import SwiftUI

enum SkillType: String, Codable, CaseIterable {
    case fog
    case swap
    case freeze

    var color: Color {
        switch self {
        case .fog: return .brown
        case .swap: return .indigo
        case .freeze: return Constants.freezeColor
        }
    }
}

struct SkillPickup: Codable, Hashable, Identifiable {
    let row: Int
    let col: Int
    let skill: SkillType
    var id: String { "\(row)-\(col)" }
}
