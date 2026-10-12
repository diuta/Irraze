import SwiftUI

struct InstructionsView: View {
    let step: Int
    let onNext: () -> Void

    private let durations: [Double] = [5, 5, 10, 10]

    var body: some View {
        VStack(spacing: step < 2 ? 20 : 30) {
            page
            CountdownBar(duration: durations[step])
                .id(step)
                .padding(.horizontal, 40)
        }
        .foregroundColor(.black)
        .task(id: step) {
            try? await Task.sleep(for: .seconds(durations[step]))
            if !Task.isCancelled { onNext() }
        }
    }

    @ViewBuilder
    private var page: some View {
        switch step {
        case 0:
            title("RACE TO THE BOTTOM OF THE MAZE")
        case 1:
            title("THERE WILL BE 3 POWERS ACROSS THE MAZE....")
        case 2:
            power(.freeze, "Freeze opponent's movement")
            power(.swap, "Swap position with the opponent's")
            power(.fog, "Fog opponent's vision")
        default:
            VStack {
                ForEach([-20, 20], id: \.self) { x in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .offset(x: CGFloat(x))
                        .shadow(color: .black, radius: 0, x: 5, y: 5)
                }
            }
            VStack(spacing: 10) {
                Text("SKILL BUTTONS")
                    .font(.pixel(10))
                Text("Will be available when you picked up a skill")
                    .font(.pixel(7))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.pixel(10))
            .multilineTextAlignment(.center)
    }

    private func power(_ skill: SkillType, _ detail: String) -> some View {
        VStack(spacing: 10) {
            Circle()
                .fill(skill.color)
                .frame(width: 12, height: 12)
                .shadow(radius: 3)
            Text(skill.rawValue.uppercased())
                .font(.pixel(10))
            Text(detail)
                .font(.pixel(7))
                .multilineTextAlignment(.center)
        }
    }
}

struct CountdownBar: View {
    let duration: Double
    @State private var progress: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .stroke(Color.black, lineWidth: 2)

                Rectangle()
                    .fill(Color.black)
                    .frame(width: max(0, geo.size.width * progress - 4))
                    .padding(2)
            }
        }
        .frame(height: 12)
        .onAppear {
            withAnimation(.linear(duration: duration)) {
                progress = 1.0
            }
        }
    }
}
