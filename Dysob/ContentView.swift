import SwiftUI

struct ContentView: View {
    let size: CGFloat = Constants.size
    let spacing: CGFloat = Constants.spacing
    let maze = Constants.maze
    let maxRowView: Int = Constants.maxRowView
    let cameraBoundary: Int = Constants.cameraBoundary
    
    let step: CGFloat = Constants.step
    let maxX: CGFloat = Constants.maxX
    let maxY: CGFloat = Constants.maxY

    @State private var position = CGPoint.zero
    @State private var isFinished = false
    
    var startPosition: CGPoint {
        CGPoint(
            x: colToPixel(col: 1),
            y: rowToPixel(row: 1)
        )
    }

    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Map()
                Obstacles(
                    position: position
                )
                Player(
                    position: position
                )
                
                if isFinished {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                }
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
        let newRow = pixelToRow(pixel: position.y + y)
        let newCol = pixelToCol(pixel: position.x + x)

        guard newRow >= 0, newRow < maze.rows,
              newCol >= 0, newCol < maze.cols,
              !maze.isWall(row: newRow, col: newCol) else { return }

        position.x += x
        position.y += y
        
        withAnimation {
            isFinished = maze.isFinish(row: newRow, col: newCol)
        }
    }
}

#Preview {
    ContentView()
}
