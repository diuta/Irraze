import SwiftUI

struct Obstacles: View {
    let maze: MazeGenerator2
    let position: CGPoint
    
    private let step = Constants.step
    private let maxY = Constants.maxY
    private let maxX = Constants.maxX
    private let size = Constants.size
    private let maxRowView = Constants.maxRowView
    private let cameraBoundary = Constants.cameraBoundary
    
    private var cameraShift: Int {
        let currRow = pixelToRow(pixel: position.y)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        return !isAtBoundary ? 0 : isMaxShift ? maxShift : currRow - cameraBoundary
    }
    
    private var shiftLimit: Int {
        return (maxRowView + cameraShift) >= maze.rows ? maze.rows : (maxRowView + cameraShift)
    }

    var body: some View {
        ZStack {
            ForEach(cameraShift..<shiftLimit, id: \.self) { row in
                ForEach(0..<maze.cols, id: \.self) { col in
                    if maze.isWall(row: row, col: col) {
                        treeIcon(row: row, col: col)
                    }
                    if maze.isFinish(row: row, col: col) {
                        let xOffset = colToPixel(col: col)
                        let yOffset = rowToPixel(row: row-cameraShift)
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: size, height: size)
                            .offset(x: xOffset, y: yOffset)
                    }
                }
            }
        }
    }

    private func treeIcon(row: Int, col: Int) -> some View {
        let xOffset = colToPixel(col: col)
        let yOffset = rowToPixel(row: row-cameraShift)

        return Image(systemName: "tree")
            .frame(width: size, height: size)
            .offset(x: xOffset, y: yOffset)
    }
}
