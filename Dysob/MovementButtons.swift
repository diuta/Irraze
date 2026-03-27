import SwiftUI

struct MovementButtons : View {
    let label : String
    let width : CGFloat
    let height : CGFloat
    let action : () -> Void
    
    var body : some View {
        Button(action: action) {
            Image(systemName: label)
                .font(.title)
                .frame(width: width, height: height)
                .background(Color.yellow)
                .foregroundColor(.white)
//                .cornerRadius(12)
        }
    }
}
