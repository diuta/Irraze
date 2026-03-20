import Foundation

struct MazeGenerator {
    let rows: Int
    let cols: Int
    private(set) var grid: [[Bool]]

    init(rows: Int, cols: Int) {
        let r = rows % 2 == 0 ? rows + 1 : rows
        let c = cols % 2 == 0 ? cols + 1 : cols
        self.rows = r
        self.cols = c

        self.grid = Array(repeating: Array(repeating: true, count: c), count: r)

        grid[1][1] = false
        var visited = Array(repeating: Array(repeating: false, count: c), count: r)
        generate(row: 1, col: 1, visited: &visited)
    }

    func isWall(row: Int, col: Int) -> Bool {
        guard row >= 0, row < rows, col >= 0, col < cols else { return true }
        return grid[row][col]
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
