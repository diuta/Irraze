import Foundation

enum PlayerMessage: Codable {
    case position(x: Double, y: Double)
    case maze(grid: [[Bool]])
    case gameOver
    case restart(grid: [[Bool]])
    case fogOfWar
    case swap(x: Double, y: Double)
}
