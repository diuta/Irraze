import Foundation
import SwiftUI

enum SkillType: String, Codable {
    case fog
    case swap
    case freeze

    var color: Color {
        switch self {
        case .fog:  return .brown
        case .swap: return .indigo
        case .freeze: return (Constants.freezeColor)
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
    case restartRequest
    
    case fogOfWar
    case swap(x: Double, y: Double)
    case freeze
    
    case pickups(fog: [SkillPickup], swap: [SkillPickup], freeze: [SkillPickup])
    case pickupCollected(skillType: SkillType, row: Int, col: Int)
}
