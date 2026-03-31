import Foundation
import SwiftUI

// SkillType is the single source of truth for every skill in the game.
// To add a new skill, add a new case here — everything else follows from it.
enum SkillType: String, Codable {
    case fog
    case swap

    // Each skill declares its own button/pickup color.
    // This way you never have to hardcode colors in UI files.
    var color: Color {
        switch self {
        case .fog:  return .brown
        case .swap: return .indigo
        }
    }
}

struct SkillPickup: Codable, Equatable, Hashable, Identifiable {
    let row: Int
    let col: Int
    var id: String { "\(row)-\(col)" }
}

enum PlayerMessage: Codable {
    case position(x: Double, y: Double)
    case maze(grid: [[Bool]])
    case gameOver
    case restart(grid: [[Bool]])
    case fogOfWar
    case swap(x: Double, y: Double)
    case pickups(fog: [SkillPickup], swap: [SkillPickup])
    case pickupCollected(isFog: Bool, row: Int, col: Int)
    case restartRequest
}
