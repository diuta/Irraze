import Foundation
import SwiftUI

struct UserInput: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
    @State private var position = CGPoint.zero
    @State private var mazeReady = false
    @State private var showPeerSheet = false
    @State private var isFinished = false
    
    var body: some View {
        movementButtons
    }
    
    private var movementButtons: some View {
        HStack() {
            HStack(spacing: 0) {
                MovementButtons(label: "", width: 50, height: 40) { move(x: -Constants.step, y: 0) }
                VStack(spacing: 0) {
                    MovementButtons(label: "", width: 40, height: 60) { move(x: 0, y: -Constants.step) }
                    MovementButtons(label: "", width: 40, height: 60) { move(x: 0, y: Constants.step) }
                }
                MovementButtons(label: "", width: 50, height: 40) { move(x: Constants.step, y: 0) }
            }
            
            VStack{
                Circle()
                    .fill(Color.red)
                    .frame(width: 70, height: 70)
            }
        }
        .padding(.bottom, 30)
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
    UserInput()
}
