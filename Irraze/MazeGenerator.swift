import Foundation

struct MazeGenerator {
    let rows: Int
    let cols: Int
    private(set) var grid: [[Bool]]

    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols

        self.grid = Array(repeating: Array(repeating: true, count: cols), count: rows)

        grid[1][1] = false
        var visited = Array(repeating: Array(repeating: false, count: cols), count: rows)
        generate(row: 1, col: 1, visited: &visited)
    }

    func isWall(row: Int, col: Int) -> Bool {
        guard row >= 0, row < rows, col >= 0, col < cols else { return true }
        return grid[row][col]
    }

    func isFinish(row: Int, col: Int) -> Bool {
        return row == rows - 2 && col == cols - 2
    }

    private mutating func generate(row: Int, col: Int, visited: inout [[Bool]]) {
        visited[row][col] = true

        let directions = [(-2, 0), (2, 0), (0, -2), (0, 2)].shuffled()

        for (dr, dc) in directions {
            let newRow = row + dr
            let newCol = col + dc

            guard newRow > 0, newRow < rows - 1,
                  newCol > 0, newCol < cols - 1,
                  !visited[newRow][newCol] else { continue }

            grid[row + dr / 2][col + dc / 2] = false
            grid[newRow][newCol] = false

            generate(row: newRow, col: newCol, visited: &visited)
        }
    }
}
