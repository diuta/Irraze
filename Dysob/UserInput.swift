import Foundation
import SwiftUI

struct UserInput: View {
    @Binding var maze: MazeGenerator2
    @Binding var position: CGPoint
    @Binding var isFinished: Bool
    @ObservedObject var multipeerManager: MultipeerManager
    
    var body: some View {
        movementButtons
    }
    
    private var movementButtons: some View {
        HStack(spacing: 125) {
            HStack(spacing: 0) {
                MovementButtons(label: "", width: 50, height: 50) { move(x: -Constants.step, y: 0) }
                VStack(spacing: 0) {
                    MovementButtons(label: "", width: 50, height: 50) { move(x: 0, y: -Constants.step) }
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .background(Color.black)
                        .opacity(0.025)
                    MovementButtons(label: "", width: 50, height: 50) { move(x: 0, y: Constants.step) }
                }
                MovementButtons(label: "", width: 50, height: 50) { move(x: Constants.step, y: 0) }
            }
                        
            VStack{
                Button{
                    
                } label: {
                    Circle()
                        .fill(Color.black)
                        .opacity(0.1)
                        .frame(width: 70, height: 70)
                }
                .offset(x: -65)

                Button{
                    
                } label: {
                    Circle()
                        .fill(Color.black)
                        .opacity(0.1)
                        .frame(width: 70, height: 70)
                }
                .offset(x: 10)

            }
        }
        .padding(30)
        .padding(.bottom, 60)
    }

    func move(x: CGFloat, y: CGFloat) {
        guard multipeerManager.gameReady else { return }

        let newRow = pixelToRow(pixel: position.y + y)
        let newCol = pixelToCol(pixel: position.x + x)

        guard newRow >= 0, newRow < maze.rows,
              newCol >= 0, newCol < maze.cols,
              !maze.isFinish(
                row: pixelToRow(pixel: position.y),
                col: pixelToCol(pixel: position.x)
              ),
              !multipeerManager.opponentWon,
              !maze.isWall(row: newRow, col: newCol) else { return }

        position.x += x
        position.y += y
        multipeerManager.sendPosition(position)

        isFinished = maze.isFinish(row: newRow, col: newCol)
        
        if isFinished {
            multipeerManager.sendGameOver()
        }
    }
}

#Preview {
    UserInput(
        maze: .constant(MazeGenerator2(rows: Constants.rows, cols: Constants.cols)),
        position: .constant(.zero),
        isFinished: .constant(false),
        multipeerManager: MultipeerManager()
    )
}
