import SwiftUI

struct RemotePlayer: View {
    let remotePosition: CGPoint
    let localPosition: CGPoint
    let color: Color
    let maze: MazeGenerator2

    private let step = Constants.step
    private let maxY = Constants.maxY
    private let cameraBoundary = Constants.cameraBoundary
    private let maxRowView = Constants.maxRowView

    private var localCameraShift: Int {
        let currRow = pixelToRow(pixel: localPosition.y)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        return !isAtBoundary ? 0 : isMaxShift ? maxShift : currRow - cameraBoundary
    }

    private var remoteRow: Int {
        pixelToRow(pixel: remotePosition.y)
    }

    private var isVisible: Bool {
        let row = remoteRow
        return row >= localCameraShift && row < localCameraShift + maxRowView
    }

    var remoteVisualY: CGFloat {
        let visualRow = remoteRow - localCameraShift
        return rowToPixel(row: visualRow)
    }

    var body: some View {
        if isVisible {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .offset(x: remotePosition.x, y: remoteVisualY)
        }
    }
}
