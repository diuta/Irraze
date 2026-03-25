import Foundation
import SwiftUI

struct Player: View {
    let maze: MazeGenerator2
    let position: CGPoint

    private let step = Constants.step
    private let maxY = Constants.maxY
    private let cameraBoundary = Constants.cameraBoundary
    private let maxRowView = Constants.maxRowView
    
    var playerRowView: CGFloat {
        let currRow = pixelToRow(pixel: position.y)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        let boundaryCoordinate = rowToPixel(row: cameraBoundary)
        let postBoundaryCoordinate = rowToPixel(row: currRow - maxShift)
        return !isAtBoundary ? position.y : isMaxShift ? postBoundaryCoordinate : boundaryCoordinate
    }

    var body: some View {
        VStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 15, height: 15)
                .offset(x: position.x, y: playerRowView)
                .animation(.spring(), value: position)
        }
    }
}
