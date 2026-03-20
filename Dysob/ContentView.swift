import SwiftUI

struct ContentView: View {
    let size: CGFloat = 25
    let spacing: CGFloat = 10
    let rows: Int = 15
    let cols: Int = 10
    
    @State private var position = CGPoint.zero
    var step: CGFloat { spacing + size }
    var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    var maxY: CGFloat { CGFloat(rows - 1) / 2 * step }
    var startPosition: CGPoint { CGPoint(x: -maxX, y: -maxY) }
    
    var body: some View {
        VStack {
            ZStack{
                Map(rows: rows, cols: cols, spacing: spacing, size: size)
                Player(position: position)
            }
            
            Spacer()
            
            VStack (spacing: 10){
                MovementButtons(label: "↑") { move(x: 0, y: -step) }
            }
            HStack (spacing: 10){
                MovementButtons(label: "←") { move(x: -step, y: 0) }
                MovementButtons(label: "↓") { move(x: 0, y: step) }
                MovementButtons(label: "→") { move(x: step, y: 0) }
            }
        }
        .onAppear {
            position = startPosition
        }
    }
    
    func move(x: CGFloat, y: CGFloat){
        let newX = position.x + x
        let newY = position.y + y
        
        if newX >= -maxX && newX <= maxX {
            position.x = newX
        }
        
        if newY >= -maxY && newY <= maxY {
            position.y = newY
        }
    }
}

#Preview {
    ContentView()
}
