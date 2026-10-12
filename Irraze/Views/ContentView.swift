import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()

    private let stage = CGSize(width: 402, height: 874)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image("bmo2")
                    .resizable()
                    .frame(width: stage.width, height: stage.height)

                ZStack {
                    board
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 140)

                ConnectionToolbarView(network: game.network)
                    .padding(.top, 529)

                ControlsView(game: game)
                    .padding(.top, 583)
            }
            .frame(width: stage.width, height: stage.height, alignment: .topLeading)
            .scaleEffect(min(geo.size.width / stage.width, geo.size.height / stage.height))
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(Constants.backgroundColor)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var board: some View {
        if !game.isReady {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.black)
                Text("Waiting for opponent...")
                    .font(.pixel(10))
                    .foregroundColor(.black)
            }
            .padding(.top, 117)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
        } else if game.outcome != .playing {
            GameOverView(won: game.outcome == .won) {
                haptic()
                game.restart()
            }
            .padding(.top, 117)
        } else if let step = game.tutorialStep {
            InstructionsView(step: step) { game.nextTutorialStep() }
                .frame(width: 261, height: 272)
        } else {
            MazeView(game: game)
        }
    }
}

#Preview {
    ContentView()
}
