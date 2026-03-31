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
                Button {
                    haptic()
                    move(x: -Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(multipeerManager.isFrozen ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                .disabled(multipeerManager.isFrozen)
                
                VStack(spacing: 0) {
                    Button {
                        haptic()
                        move(x: 0, y: -Constants.step)
                    } label: {
                        Rectangle()
                            .fill(multipeerManager.isFrozen ? Color.gray : Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                    .disabled(multipeerManager.isFrozen)
                    
                    Rectangle()
                        .fill(multipeerManager.isFrozen ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                    
                    Button {
                        haptic()
                        move(x: 0, y: Constants.step)
                    } label: {
                        Rectangle()
                            .fill(multipeerManager.isFrozen ? Color.gray : Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                    .disabled(multipeerManager.isFrozen)
                    
                }
                Button {
                    haptic()
                    move(x: Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(multipeerManager.isFrozen ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                .disabled(multipeerManager.isFrozen)
            }
            .compositingGroup()
            .shadow(color: .black, radius: 0, x: 7, y: 7)
                        
            VStack {
                let slot0 = multipeerManager.skillSlots[0]
                Button {
                    haptic(.medium)
                    useSkillInSlot(0)
                } label: {
                    Circle()
                        .fill(slot0?.color ?? Color.gray)
                        .frame(width: 70, height: 70)
                }
                .disabled(slot0 == nil)   // can't press an empty slot
                .offset(x: -65)
                .shadow(color: .black, radius: 0, x: 5, y: 5)

                let slot1 = multipeerManager.skillSlots[1]
                Button {
                    haptic(.medium)
                    useSkillInSlot(1)
                } label: {
                    Circle()
                        .fill(slot1?.color ?? Color.gray)
                        .frame(width: 70, height: 70)
                }
                .disabled(slot1 == nil)
                .offset(x: 10)
                .shadow(color: .black, radius: 0, x: 5, y: 5)
            }
        }
        .padding(30)
        .padding(.bottom, 60)
    }

    func move(x: CGFloat, y: CGFloat) {
        guard multipeerManager.gameReady else { return }
        guard !multipeerManager.isFrozen else { return }

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
        SoundManager.shared.play("move")

        isFinished = maze.isFinish(row: newRow, col: newCol)
        
        if isFinished {
            multipeerManager.sendGameOver()
        }
    }

    func useSkillInSlot(_ index: Int) {
        guard multipeerManager.gameReady,
              !isFinished,
              !multipeerManager.opponentWon,
              let skill = multipeerManager.skillSlots[index] else { return }

        switch skill {

        case .fog:
            multipeerManager.sendFogOfWar()
            multipeerManager.clearSkillSlot(index)
            SoundManager.shared.play("skill")

        case .swap:
            guard let remotePos = multipeerManager.remotePosition else { return }
            let myPos = position
            multipeerManager.sendSwap(myPosition: myPos)
            position = remotePos
            multipeerManager.sendPosition(position)   
            multipeerManager.clearSkillSlot(index)
            SoundManager.shared.play("skill")
            
        case .freeze:
            multipeerManager.sendFreeze()
            multipeerManager.clearSkillSlot(index)
            SoundManager.shared.play("skill")
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
