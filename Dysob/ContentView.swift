import SwiftUI

struct ContentView: View {
    let size: CGFloat = 25
    let spacing: CGFloat = 5
    let maze = MazeGenerator2(rows: 8, cols: 5)
    let maxRowView: Int = 5
    let cameraBoundary: Int = 3

    @State private var position = CGPoint.zero
    var step: CGFloat { spacing + size }
    var maxX: CGFloat { CGFloat(maze.cols - 1) / 2 * step }
    var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }

    var startPosition: CGPoint {
        CGPoint(
            x: coordinateToPixel(coordinate: 1, step: step, max: maxX),
            y: coordinateToPixel(coordinate: 1, step: step, max: maxY)
        )
    }

    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Map(
                    maze: maze,
                    maxRowView: maxRowView,
                    spacing: spacing,
                    size: size
                )
                Obstacles(
                    maze: maze,
                    size: size,
                    spacing: spacing,
                    maxRowView: maxRowView,
                    cameraBoundary: cameraBoundary,
                    position: position,
                    step: step,
                    maxY: maxY,
                    maxX: maxX
                )
                Player(
                    position: position,
                    cameraBoundary: cameraBoundary,
                    step: step,
                    maxY: maxY,
                    maze: maze,
                    maxRowView: maxRowView
                )
            }

            Spacer()

            HStack(spacing: 10) {
                MovementButtons(label: "←") {
                    move(x: -step, y: 0)
                }
                VStack(spacing: 10) {
                    MovementButtons(label: "↑") {
                        move(x: 0, y: -step)
                    }
                    MovementButtons(label: "↓") {
                        move(x: 0, y: step)
                    }
                }
                MovementButtons(label: "→") {
                    move(x: step, y: 0)
                }
            }
        }
        .onAppear { position = startPosition }
    }

    func move(x: CGFloat, y: CGFloat) {
        let newRow = Int((position.y + y + maxY) / step)
        let newCol = Int((position.x + x + maxX) / step)

        guard newRow >= 0, newRow < maze.rows,
              newCol >= 0, newCol < maze.cols,
              !maze.isWall(row: newRow, col: newCol) else { return }

        position.x += x
        position.y += y
    }
}

#Preview {
    ContentView()
}
