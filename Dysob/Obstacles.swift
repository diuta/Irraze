import SwiftUI

struct Obstacles: View {
    let maze: MazeGenerator
    let size: CGFloat
    let spacing: CGFloat
    let maxRowView: Int
    let cameraBoundary: Int
    let position: CGPoint
    let step: CGFloat
    let maxY: CGFloat
    
    private var cameraShift: Int {
        let currRow = coordinateToRow(position: position.y, step: step, max: maxY)
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
                }
            }
        }
    }

    private func treeIcon(row: Int, col: Int) -> some View {
        let maxX = CGFloat(maze.cols - 1) / 2 * step
        let maxY = CGFloat(maxRowView - 1) / 2 * step
        let x = CGFloat(col) * step - maxX
        let y = CGFloat(row - cameraShift) * step - maxY

        return Image(systemName: "tree")
            .frame(width: size, height: size)
            .offset(x: x, y: y)
    }
}
