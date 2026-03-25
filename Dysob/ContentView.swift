import SwiftUI

struct ContentView: View {
    @State private var maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
    
    let size: CGFloat = Constants.size
    let spacing: CGFloat = Constants.spacing
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
        ZStack {
            VStack {
                Spacer()
                
                ZStack {
                    Map(maze: maze)
                    Obstacles(
                        maze: maze,
                        position: position
                    )
                    Player(
                        maze: maze,
                        position: position
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
            
            if isFinished {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                VStack{
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Button("Restart") {
                        maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
                        isFinished = false
                        position = startPosition
                    }.font(Font.title.bold())
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
