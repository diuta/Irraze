@main
enum GameChecks {
    static func main() {
        for _ in 0..<50 {
            let maze = Maze(rows: Constants.rows, cols: Constants.cols)

            precondition(!maze.isWall(row: 1, col: 1), "host start is a wall")
            precondition(!maze.isWall(row: 1, col: maze.cols - 2), "guest start is a wall")
            precondition(!maze.isWall(row: maze.rows - 2, col: maze.cols - 2), "finish is a wall")
            for row in 0..<maze.rows {
                precondition(maze.isWall(row: row, col: 0) && maze.isWall(row: row, col: maze.cols - 1), "side wall open")
            }
            for col in 0..<maze.cols {
                precondition(maze.isWall(row: 0, col: col) && maze.isWall(row: maze.rows - 1, col: col), "top/bottom wall open")
            }

            var reached: Set<[Int]> = [[1, 1]]
            var queue = [[1, 1]]
            while let cell = queue.popLast() {
                for (dr, dc) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                    let next = [cell[0] + dr, cell[1] + dc]
                    if !maze.isWall(row: next[0], col: next[1]), reached.insert(next).inserted {
                        queue.append(next)
                    }
                }
            }
            let openCount = maze.grid.joined().filter { !$0 }.count
            precondition(reached.count == openCount, "some open square is unreachable")

            let pickups = maze.randomPickups(perSkill: Constants.pickupsPerSkill)
            precondition(Set(pickups.map(\.id)).count == pickups.count, "two pickups on one square")
            for skill in SkillType.allCases {
                precondition(pickups.filter { $0.skill == skill }.count == Constants.pickupsPerSkill, "wrong pickup count")
            }
            for p in pickups {
                precondition(!maze.isWall(row: p.row, col: p.col), "pickup on a wall")
                precondition(!maze.isFinish(row: p.row, col: p.col), "pickup on the finish")
                precondition(!(p.row == 1 && (p.col == 1 || p.col == maze.cols - 2)), "pickup on a start")
            }
        }

        for row in 0..<Constants.rows {
            precondition(Grid.row(y: Grid.y(row: row)) == row, "row round trip")
        }
        for col in 0..<Constants.cols {
            precondition(Grid.col(x: Grid.x(col: col)) == col, "col round trip")
        }

        precondition(Grid.cameraShift(row: 1, mazeRows: Constants.rows) == 0, "camera top")
        precondition(Grid.cameraShift(row: Constants.rows - 2, mazeRows: Constants.rows) == Constants.rows - Constants.maxRowView, "camera bottom")
        for row in 0..<Constants.rows {
            let shift = Grid.cameraShift(row: row, mazeRows: Constants.rows)
            precondition((shift..<shift + Constants.maxRowView).contains(row), "player off screen")
            precondition(shift >= 0 && shift + Constants.maxRowView <= Constants.rows, "camera out of bounds")
        }

        print("All checks passed")
    }
}
