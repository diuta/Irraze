import Foundation

struct MazeGenerator {
    let rows: Int
    let cols: Int

    // walls[row][col] = set of directions where a wall EXISTS
    // We store which walls are *removed* (i.e. open passages)
    private(set) var walls: [[Set<Direction>]] = []

    enum Direction: CaseIterable {
        case up, down, left, right

        var offset: (row: Int, col: Int) {
            switch self {
            case .up:    return (-1,  0)
            case .down:  return ( 1,  0)
            case .left:  return ( 0, -1)
            case .right: return ( 0,  1)
            }
        }

        var opposite: Direction {
            switch self {
            case .up:    return .down
            case .down:  return .up
            case .left:  return .right
            case .right: return .left
            }
        }
    }

    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        // All cells start fully walled — no open passages
        self.walls = Array(repeating: Array(repeating: [], count: cols), count: rows)
        
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        generate(row: 0, col: 0, visited: &visited)
    }

    // Returns true if moving from (row, col) in `direction` is open (no wall)
    func isOpen(row: Int, col: Int, direction: Direction) -> Bool {
        walls[row][col].contains(direction)
    }

    // Returns true if a cell should be a solid wall/obstacle (surrounded, never carved)
    func isWall(row: Int, col: Int) -> Bool {
        walls[row][col].isEmpty
    }

    private mutating func generate(row: Int, col: Int, visited: inout [[Bool]]) {
        visited[row][col] = true

        for direction in Direction.allCases.shuffled() {
            let newRow = row + direction.offset.row
            let newCol = col + direction.offset.col

            guard newRow >= 0, newRow < rows,
                  newCol >= 0, newCol < cols,
                  !visited[newRow][newCol] else { continue }

            // Carve passage: mark both sides open
            walls[row][col].insert(direction)
            walls[newRow][newCol].insert(direction.opposite)

            generate(row: newRow, col: newCol, visited: &visited)
        }
    }
}
