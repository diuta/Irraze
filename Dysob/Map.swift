import SwiftUI

public struct Map: View {
    var maze: MazeGenerator2
    var maxRowView: Int
    var spacing: CGFloat
    var size: CGFloat
    
    public var body: some View {
        VStack (spacing: spacing) {
            ForEach(0..<maxRowView, id: \.self) { row in
                HStack (spacing: spacing){
                    ForEach(0..<maze.cols, id: \.self) { col in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                    }
                }
            }
        }
    }
}
