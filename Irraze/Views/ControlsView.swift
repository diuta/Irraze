import SwiftUI
import UIKit

func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

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
            .font(.pixel(5))
            .foregroundColor(.white.opacity(0.85))
            .rotationEffect(.degrees(angleDeg + 90))
            .offset(x: radius * cos(angleRad), y: radius * sin(angleRad))
    }
}

struct ControlsView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        HStack(spacing: 125) {
            HStack(spacing: 0) {
                arrowButton(dx: -1, dy: 0)
                VStack(spacing: 0) {
                    arrowButton(dx: 0, dy: -1)
                    Rectangle()
                        .fill(padColor)
                        .frame(width: 50, height: 50)
                    arrowButton(dx: 0, dy: 1)
                }
                arrowButton(dx: 1, dy: 0)
            }
            .compositingGroup()
            .shadow(color: .black, radius: 0, x: 7, y: 7)

            VStack {
                skillButton(0, arcEnd: 90)
                    .offset(x: -65)
                skillButton(1, arcEnd: 0)
            }
        }
        .padding(30)
        .padding(.bottom, 60)
    }

    private var padColor: Color { game.canMove ? Constants.moveButtonColor : .gray }

    private func arrowButton(dx: Int, dy: Int) -> some View {
        Button {
            haptic()
            game.move(dx: dx, dy: dy)
        } label: {
            Rectangle()
                .fill(padColor)
                .frame(width: 50, height: 50)
        }
        .disabled(!game.canMove)
    }

    @ViewBuilder
    private func skillButton(_ slot: Int, arcEnd: CGFloat) -> some View {
        let skill = game.skillSlots[slot]
        ZStack {
            Button {
                haptic(.medium)
                game.useSkill(slot)
            } label: {
                Circle()
                    .fill(skill?.color ?? Color.gray)
                    .frame(width: 70, height: 70)
            }
            .disabled(skill == nil)
            .shadow(color: .black, radius: 0, x: 5, y: 5)

            if let skill {
                ArcText(text: "\(skill.rawValue) is ready!", radius: 28, startAngle: -180, endAngle: arcEnd)
            }
        }
    }
}

#Preview {
    ControlsView(game: GameModel())
}
