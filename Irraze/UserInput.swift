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
                        .fill(Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                VStack(spacing: 0) {
                    Button {
                        haptic()
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
                        haptic()
                        move(x: 0, y: Constants.step)
                    } label: {
                        Rectangle()
                            .fill(Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                }
                Button {
                    haptic()
                    move(x: Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
            }
            .compositingGroup()
            .shadow(color: .black, radius: 0, x: 7, y: 7)
                        
            VStack {
                // --- Button Slot 0 (top button) ---
                // Displays whatever skill was picked up FIRST.
                // Gray and disabled when empty; colored and active when a skill is stored.
                let slot0 = multipeerManager.skillSlots[0]
                Button {
                    haptic(.medium)
                    useSkillInSlot(0)
                } label: {
                    Circle()
                        // skill?.color gives the skill's own color; nil falls back to gray
                        .fill(slot0?.color ?? Color.gray)
                        .frame(width: 70, height: 70)
                }
                .disabled(slot0 == nil)   // can't press an empty slot
                .offset(x: -65)
                .shadow(color: .black, radius: 0, x: 5, y: 5)

                // --- Button Slot 1 (bottom button) ---
                // Displays whatever skill was picked up SECOND
                // (or first if slot 0 was already freed and refilled).
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

    // Called when the player taps a skill button.
    // index = 0 for the top button, 1 for the bottom button.
    //
    // This single function replaces useFogOfWar() and useSwap().
    // It reads whatever skill is in the given slot, applies its effect,
    // then empties the slot so the next pickup can fill it.
    func useSkillInSlot(_ index: Int) {
        // Safety checks: game must be running and the slot must not be empty
        guard multipeerManager.gameReady,
              !isFinished,
              !multipeerManager.opponentWon,
              let skill = multipeerManager.skillSlots[index] else { return }

        switch skill {

        case .fog:
            // Tell opponent they are fogged, then empty this slot
            multipeerManager.sendFogOfWar()
            multipeerManager.clearSkillSlot(index)
            SoundManager.shared.play("skill")

        case .swap:
            // We need to know where the opponent currently is to teleport there.
            // If we don't know yet (remotePosition is nil), do nothing.
            guard let remotePos = multipeerManager.remotePosition else { return }
            let myPos = position
            multipeerManager.sendSwap(myPosition: myPos) // opponent moves to our old spot
            position = remotePos                          // we move to their spot
            multipeerManager.sendPosition(position)       // tell everyone our new position
            multipeerManager.clearSkillSlot(index)
            SoundManager.shared.play("skill")
        }
        // NOTE: To add a new skill, just add a new case here.
        // The compiler will warn you if you forget to handle a SkillType case.
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
