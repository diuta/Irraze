import SwiftUI

struct RemotePlayer: View {
    let remotePosition: CGPoint
    let localPosition: CGPoint
    let color: Color
    let cameraBoundary: Int
    let step: CGFloat
    let maxY: CGFloat
    let maze: MazeGenerator2
    let maxRowView: Int

    private var localCameraShift: Int {
        let currRow = pixelToRow(pixel: localPosition.y, step: step, max: maxY)
        let maxShift = maze.rows - maxRowView
        let isAtBoundary = currRow >= cameraBoundary
        let isMaxShift = (currRow - cameraBoundary) >= maxShift
        return !isAtBoundary ? 0 : isMaxShift ? maxShift : currRow - cameraBoundary
    }

    private var remoteRow: Int {
        pixelToRow(pixel: remotePosition.y, step: step, max: maxY)
    }

    private var isVisible: Bool {
        let row = remoteRow
        return row >= localCameraShift && row < localCameraShift + maxRowView
    }

    var remoteVisualY: CGFloat {
        let visualRow = remoteRow - localCameraShift
        return rowToPixel(row: visualRow, step: step, max: maxY)
    }

    var body: some View {
        if isVisible {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .offset(x: remotePosition.x, y: remoteVisualY)
                .animation(.spring(), value: remotePosition)
        }
    }
}
