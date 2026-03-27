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
        HStack() {
            HStack(spacing: 0) {
                MovementButtons(label: "", width: 60, height: 40) { move(x: -Constants.step, y: 0) }
                VStack(spacing: 0) {
                    MovementButtons(label: "", width: 40, height: 70) { move(x: 0, y: -Constants.step) }
                    MovementButtons(label: "", width: 40, height: 70) { move(x: 0, y: Constants.step) }
                }
                MovementButtons(label: "", width: 60, height: 40) { move(x: Constants.step, y: 0) }
            }
            
            Spacer()
            
            VStack{
                Circle()
                    .fill(Color.red)
                    .frame(width: 70, height: 70)
                    .offset(x: -50)
                Circle()
                    .fill(Color.red)
                    .frame(width: 70, height: 70)
            }
        }
        .padding(30)
        .padding(.bottom, 60)
        .shadow(radius: 10)
//        .background(Color.blue)
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
