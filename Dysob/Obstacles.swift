import SwiftUI

struct Obstacles: View {
    let maze: MazeGenerator2
    let size: CGFloat
    let spacing: CGFloat
    let maxRowView: Int
    let cameraBoundary: Int
    let position: CGPoint
    let step: CGFloat
    let maxY: CGFloat
    let maxX: CGFloat
    
    private var cameraShift: Int {
        let currRow = pixelToCoordinate(pixel: position.y, step: step, max: maxY)
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
                        let xOffset = coordinateToPixel(coordinate: col, step: step, max: maxX)
                        let yOffset = coordinateToPixel(coordinate: row-cameraShift, step: step, max: maxY)
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
        let xOffset = coordinateToPixel(coordinate: col, step: step, max: maxX)
        let yOffset = coordinateToPixel(coordinate: row-cameraShift, step: step, max: maxY)

        return Image(systemName: "tree")
            .frame(width: size, height: size)
            .offset(x: xOffset, y: yOffset)
    }
}
