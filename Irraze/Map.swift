import SwiftUI

public struct Map: View {
    private let cols = Constants.cols
    private let maxRowView = Constants.maxRowView
    private let spacing = Constants.spacing
    private let size = Constants.size
    
    public var body: some View {
        VStack (spacing: spacing) {
            ForEach(0..<maxRowView, id: \.self) { row in
                HStack (spacing: spacing){
                    ForEach(0..<cols, id: \.self) { col in
                        Rectangle()
                            .frame(width: size, height: size)
                            .opacity(0.002)
                    }
                }
            }
        }
    }
}
