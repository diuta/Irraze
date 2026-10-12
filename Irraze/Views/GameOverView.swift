import SwiftUI

struct GameOverView: View {
    let won: Bool
    let onTryAgain: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(won ? "YOU WIN!" : "YOU LOSE!")
                .font(.pixel(20))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)

            Button(action: onTryAgain) {
                Text("Try Again")
                    .font(.pixel(10))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Constants.catridgeColor)
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                    )
            }
        }
    }
}
