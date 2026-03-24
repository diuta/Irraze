import SwiftUI

struct ContentView: View {
    let size: CGFloat = 25
    let spacing: CGFloat = 5
    let maze = MazeGenerator2(rows: 80, cols: 10)
    let maxRowView: Int = 10
    let cameraBoundary: Int = 5

    var rows: Int { maze.rows }
    var cols: Int { maze.cols }

    @State private var position = CGPoint.zero
    var step: CGFloat { spacing + size }
    var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }

    var startPosition: CGPoint { CGPoint(x: step - maxX, y: step - maxY) }

    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Map(rows: maxRowView, cols: maze.cols, spacing: spacing, size: size)
                Obstacles(maze: maze, size: size, spacing: spacing, maxRowView: maxRowView, cameraBoundary: cameraBoundary, position: position, step: step, maxY: maxY)
                Player(position: position, cameraBoundary: cameraBoundary, step: step, maxY: maxY, maze: maze, maxRowView: maxRowView)
            }

            Spacer()

            HStack(spacing: 10) {
                MovementButtons(label: "←") { move(x: -step, y: 0) }
                VStack(spacing: 10) {
                    MovementButtons(label: "↑") { move(x: 0, y: -step) }
                    MovementButtons(label: "↓") { move(x: 0, y: step) }
                }
                MovementButtons(label: "→") { move(x: step, y: 0) }
            }
        }
        .onAppear { position = startPosition }
    }

    func move(x: CGFloat, y: CGFloat) {
        let newRow = Int((position.y + y + maxY) / step)
        let newCol = Int((position.x + x + maxX) / step)

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
