import SwiftUI

struct MovementButtons : View {
    let label : String
    let action : () -> Void
    
    var body : some View {
        Button(label, action: action)
            .font(.title2)
            .frame(width: 70, height: 70)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .contentShape(Rectangle())
    }
}
