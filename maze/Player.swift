import Foundation
import SwiftUI

struct Player: View {
    let position: CGPoint

    var body: some View {
        VStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 15, height: 15)
                .offset(x: position.x, y: position.y)
                .animation(.spring(), value: position)
        }
    }
}
