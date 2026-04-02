import SwiftUI

struct GameOverView: View {
    let isFinished: Bool
    let onTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 16){
            if isFinished {
                Text("YOU WIN!")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
            } else {
                Text("YOU LOSE!")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
            }
            
            Button {
                onTryAgain()
            } label: {
                Text("Try Again")
                    .font(.custom("PressStart2P-Regular", size: 10))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(Constants.catridgeColor))
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                    )
            }
        }
    }
}
