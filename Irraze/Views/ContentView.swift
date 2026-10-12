import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()

    var body: some View {
        GeometryReader { geo in
            Image("bmo2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ZStack(alignment: .topLeading) {
                ZStack {
                    board(geo.size)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, geo.size.height * 0.10)

                ConnectionToolbarView(network: game.network)
                    .padding(.top, geo.size.height * 0.6)

                ControlsView(game: game)
                    .padding(.top, geo.size.height * 0.67)
            }
        }
    }

    @ViewBuilder
    private func board(_ size: CGSize) -> some View {
        if !game.isReady {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.black)
                Text("Waiting for opponent...")
                    .font(.pixel(10))
                    .foregroundColor(.black)
            }
            .padding(.top, size.height * 0.15)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        } else if game.outcome != .playing {
            GameOverView(won: game.outcome == .won) {
                haptic()
                game.restart()
            }
            .padding(.top, size.height * 0.15)
        } else if let step = game.tutorialStep {
            InstructionsView(step: step) { game.nextTutorialStep() }
                .frame(width: size.width * 0.65, height: size.height * 0.35)
        } else {
            MazeView(game: game)
        }
    }
}

#Preview {
    ContentView()
}
