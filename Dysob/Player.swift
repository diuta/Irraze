import Foundation
import SwiftUI

struct Player: View {
    let position: CGPoint
    let color: Color
    let cameraBoundary: Int
    let step: CGFloat
    let maxY: CGFloat
    let maze: MazeGenerator2
    let maxRowView: Int
    
    var playerRowView: CGFloat {
        let currRow = pixelToRow(pixel: position.y, step: step, max: maxY)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        let boundaryCoordinate = rowToPixel(row: cameraBoundary, step: step, max: maxY)
        let postBoundaryCoordinate = rowToPixel(row: currRow - maxShift, step: step, max: maxY)
        return !isAtBoundary ? position.y : isMaxShift ? postBoundaryCoordinate : boundaryCoordinate
    }

    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .offset(x: position.x, y: playerRowView)
                .animation(.spring(), value: position)
        }
    }
}
