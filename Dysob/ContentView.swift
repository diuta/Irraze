import SwiftUI

struct ContentView: View {
    let size: CGFloat = 25
    let spacing: CGFloat = 5
    let maze = MazeGenerator(rows: 20, cols: 10)

    var rows: Int { maze.rows }
    var cols: Int { maze.cols }

    @State private var position = CGPoint.zero
    var step: CGFloat { spacing + size }
    var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    var maxY: CGFloat { CGFloat(rows - 1) / 2 * step }

    var startPosition: CGPoint { CGPoint(x: step - maxX, y: step - maxY) }

    var body: some View {
        VStack {
            ZStack {
                Map(rows: rows, cols: cols, spacing: spacing, size: size)
                Obstacles(maze: maze, size: size, spacing: spacing)
                Player(position: position)
            }

            Spacer()

            VStack(spacing: 10) {
                MovementButtons(label: "↑") { move(x: 0, y: -step) }
            }
            HStack(spacing: 10) {
                MovementButtons(label: "←") { move(x: -step, y: 0) }
                MovementButtons(label: "↓") { move(x: 0, y: step) }
                MovementButtons(label: "→") { move(x: step, y: 0) }
            }
        }
        .onAppear { position = startPosition }
    }

    func move(x: CGFloat, y: CGFloat) {
        let newRow = Int(round((position.y + y + maxY) / step))
        let newCol = Int(round((position.x + x + maxX) / step))

        guard newRow >= 0, newRow < rows,
              newCol >= 0, newCol < cols,
              !maze.isWall(row: newRow, col: newCol) else { return }

        position.x += x
        position.y += y
    }
}

#Preview {
    ContentView()
}
