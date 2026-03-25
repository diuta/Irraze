import SwiftUI

struct MovementButtons : View {
    let label : String
    let action : () -> Void
    
    var body : some View {
        Button(action: action) {
            Image(systemName: label)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
