import Foundation
import SwiftUI

struct UserInput: View {
    @Binding var maze: MazeGenerator2
    @Binding var position: CGPoint
    @Binding var isFinished: Bool
    @ObservedObject var multipeerManager: MultipeerManager
    @State private var fogCooldown = false
    @State private var swapCooldown = false
    
    var body: some View {
        movementButtons
    }
    
    private var movementButtons: some View {
        HStack(spacing: 125) {
//            HStack(spacing: 0) {
//                MovementButtons(label: "", width: 50, height: 50) { move(x: -Constants.step, y: 0) }
//                VStack(spacing: 0) {
//                    MovementButtons(label: "", width: 50, height: 50) { move(x: 0, y: -Constants.step) }
//                    Rectangle()
//                        .fill(Color(Constants.moveButtonColor))
//                        .frame(width: 50, height: 50)
//                    MovementButtons(label: "", width: 50, height: 50) { move(x: 0, y: Constants.step) }
//                }
//                MovementButtons(label: "", width: 50, height: 50) { move(x: Constants.step, y: 0) }
//            }
            
            HStack(spacing: 0) {
                Button {
                    move(x: -Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                VStack(spacing: 0) {
                    Button {
                        move(x: 0, y: -Constants.step)
                    } label: {
                        Rectangle()
                            .fill(Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                    
                    Rectangle()
                        .fill(Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                    
                    Button {
                        move(x: 0, y: Constants.step)
                    } label: {
                        Rectangle()
                            .fill(Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                }
                Button {
                    move(x: Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
            }
            .compositingGroup()
            .shadow(color: .black, radius: 0, x: 7, y: 7)
                        
            VStack{
                Button{
                    useFogOfWar()
                } label: {
                    Circle()
                        .fill(fogCooldown ? Color.gray : Color.red)
                        .frame(width: 70, height: 70)
                }
                .disabled(fogCooldown)
                .offset(x: -65)
                .shadow(color: .black, radius: 0, x: 5, y: 5)

                Button{
                    useSwap()
                } label: {
                    Circle()
                        .fill(swapCooldown ? Color.gray : Color.red)
                        .frame(width: 70, height: 70)
                }
                .disabled(swapCooldown)
                .offset(x: 10)
                .shadow(color: .black, radius: 0, x: 5, y: 5)

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

    func useFogOfWar() {
        guard multipeerManager.gameReady,
              !isFinished,
              !multipeerManager.opponentWon,
              !fogCooldown else { return }

        multipeerManager.sendFogOfWar()
        fogCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            fogCooldown = false
        }
    }

    func useSwap() {
        guard multipeerManager.gameReady,
              !isFinished,
              !multipeerManager.opponentWon,
              !swapCooldown,
              let remotePos = multipeerManager.remotePosition else { return }

        let myPos = position
        multipeerManager.sendSwap(myPosition: myPos)
        position = remotePos
        multipeerManager.sendPosition(position)

        swapCooldown = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            swapCooldown = false
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
