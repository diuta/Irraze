import Foundation

struct MazeGenerator2 {
    let rows: Int
    let cols: Int
    private(set) var grid: [[Bool]]

    init(rows: Int, cols: Int) {
        let r = rows % 2 == 0 ? rows + 1 : rows
        let c = cols % 2 == 0 ? cols + 1 : cols
        self.rows = r
        self.cols = c

        self.grid = Array(repeating: Array(repeating: true, count: c), count: r)

        generate()
    }

    func isWall(row: Int, col: Int) -> Bool {
        guard row >= 0, row < rows, col >= 0, col < cols else { return true }
        return grid[row][col]
    }
    
    func isFinish(row: Int, col: Int) -> Bool {
        return row == rows - 2 && col == cols - 2
    }

    private mutating func generate() {
        grid[1][1] = false

        var frontiers: [(Int, Int, Int, Int)] = []

        addFrontiers(row: 1, col: 1, frontiers: &frontiers)

        while !frontiers.isEmpty {
            let index = Int.random(in: 0..<frontiers.count)
            let (wallRow, wallCol, cellRow, cellCol) = frontiers[index]
            frontiers.remove(at: index)

            guard cellRow > 0, cellRow < rows - 1,
                  cellCol > 0, cellCol < cols - 1,
                  grid[cellRow][cellCol] else { continue }

            grid[wallRow][wallCol] = false
            grid[cellRow][cellCol] = false

            addFrontiers(row: cellRow, col: cellCol, frontiers: &frontiers)
        }
    }

    private func addFrontiers(row: Int, col: Int, frontiers: inout [(Int, Int, Int, Int)]) {
        let directions = [(-2, 0), (2, 0), (0, -2), (0, 2)]

        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc

            guard newRow > 0, newRow < rows - 1,
                  newCol > 0, newCol < cols - 1,
                  grid[newRow][newCol] else { continue }

            frontiers.append((row + dr / 2, col + dc / 2, newRow, newCol))
        }
    }
}
