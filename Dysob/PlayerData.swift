import Foundation

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
