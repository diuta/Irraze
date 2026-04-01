import Foundation
import SwiftUI

private struct ArcText: View {
    let text: String
    let radius: CGFloat
    let startAngle: CGFloat
    let endAngle: CGFloat

    private var characters: [Character] { Array(text) }

    var body: some View {
        ZStack {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, char in
                characterView(char: char, index: index)
            }
        }
    }

    private func characterView(char: Character, index: Int) -> some View {
        let t: CGFloat = characters.count > 1
            ? CGFloat(index) / CGFloat(characters.count - 1)
            : 0.5
        let angleDeg = startAngle + (endAngle - startAngle) * t
        let angleRad = angleDeg * .pi / 180.0

        return Text(String(char))
            .font(.custom("PressStart2P-Regular", size: 5))
            .foregroundColor(.white.opacity(0.85))
            .rotationEffect(.degrees(angleDeg + 90))
            .offset(x: radius * cos(angleRad), y: radius * sin(angleRad))
    }
}

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
                        .fill(multipeerManager.isFrozen || !multipeerManager.gameReady ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                .disabled(multipeerManager.isFrozen || !multipeerManager.gameReady)
                
                VStack(spacing: 0) {
                    Button {
                        haptic()
                        move(x: 0, y: -Constants.step)
                    } label: {
                        Rectangle()
                            .fill(multipeerManager.isFrozen || !multipeerManager.gameReady ? Color.gray : Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                    .disabled(multipeerManager.isFrozen || !multipeerManager.gameReady)
                    
                    Rectangle()
                        .fill(multipeerManager.isFrozen || !multipeerManager.gameReady ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                    
                    Button {
                        haptic()
                        move(x: 0, y: Constants.step)
                    } label: {
                        Rectangle()
                            .fill(multipeerManager.isFrozen || !multipeerManager.gameReady ? Color.gray : Color(Constants.moveButtonColor))
                            .frame(width: 50, height: 50)
                    }
                    .disabled(multipeerManager.isFrozen || !multipeerManager.gameReady)
                }
                Button {
                    haptic()
                    move(x: Constants.step, y: 0)
                } label: {
                    Rectangle()
                        .fill(multipeerManager.isFrozen || !multipeerManager.gameReady ? Color.gray : Color(Constants.moveButtonColor))
                        .frame(width: 50, height: 50)
                }
                .disabled(multipeerManager.isFrozen || !multipeerManager.gameReady)
            }
            .compositingGroup()
            .shadow(color: .black, radius: 0, x: 7, y: 7)
                        
            VStack {
                let slot0 = multipeerManager.skillSlots[0]
                ZStack {
                    Button {
                        haptic(.medium)
                        useSkillInSlot(0)
                    } label: {
                        Circle()
                            .fill(slot0?.color ?? Color.gray)
                            .frame(width: 70, height: 70)
                    }
                    .disabled(slot0 == nil)
                    .shadow(color: .black, radius: 0, x: 5, y: 5)

                    if let skill = slot0 {
                        ArcText(text: skillLabel(for: skill), radius: 28, startAngle: -180, endAngle: 90)
                    }
                }
                .offset(x: -65)

                let slot1 = multipeerManager.skillSlots[1]
                ZStack {
                    Button {
                        haptic(.medium)
                        useSkillInSlot(1)
                    } label: {
                        Circle()
                            .fill(slot1?.color ?? Color.gray)
                            .frame(width: 70, height: 70)
                    }
                    .disabled(slot1 == nil)
                    .shadow(color: .black, radius: 0, x: 5, y: 5)

                    if let skill = slot1 {
                        ArcText(text: skillLabel(for: skill), radius: 28, startAngle: -180, endAngle: 0)
                    }
                }
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
        
        DispatchQueue.global().async {
            SoundManager.shared.play("move")
        }
        
        isFinished = maze.isFinish(row: newRow, col: newCol)
        
        if isFinished {
            multipeerManager.sendGameOver()
        }
    }

    private func skillLabel(for skill: SkillType) -> String {
        switch skill {
        case .fog:    return "fog is ready!"
        case .swap:   return "swap is ready!"
        case .freeze: return "freeze is ready!"
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
