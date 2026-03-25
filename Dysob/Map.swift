import SwiftUI

public struct Map: View {
    let maze: MazeGenerator2
    private let maxRowView = Constants.maxRowView
    private let spacing = Constants.spacing
    private let size = Constants.size
    
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
