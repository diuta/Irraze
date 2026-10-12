import CoreGraphics

enum PlayerMessage: Codable {
    case position(CGPoint)
    case newRound(maze: [[Bool]], pickups: [SkillPickup])
    case restartRequest
    case gameOver
    case skill(SkillType)
    case swap(CGPoint)
    case pickupCollected(row: Int, col: Int)
}
