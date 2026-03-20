import SwiftUI

public struct Map: View {
    var rows: Int
    var cols: Int
    var spacing: CGFloat
    var size: CGFloat
    
    public var body: some View {
        let rows = rows
        let cols = cols
        let spacing = spacing
        
        VStack (spacing: spacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack (spacing: spacing){
                    ForEach(0..<cols, id: \.self) { col in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                    }
                }
            }
        }
    }
}
