import Foundation
import SwiftUI

struct Player: View {
    let position: CGPoint
    let cameraBoundary: Int
    let step: CGFloat
    let maxY: CGFloat
    let maze: MazeGenerator
    let maxRowView: Int
    
    var playerRowView: CGFloat {
        let currRow = coordinateToRow(position: position.y, step: step, max: maxY)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        let boundaryCoordinate = rowToCoordinate(coordinate: cameraBoundary, step: step, max: maxY)
        let postBoundaryCoordinate = rowToCoordinate(coordinate: currRow - maxShift, step: step, max: maxY)
        return !isAtBoundary ? position.y : isMaxShift ? postBoundaryCoordinate : boundaryCoordinate
//        return !isAtBoundary ? position.y : isMaxShift ? postBoundaryCoordinate : boundaryCoordinate
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
