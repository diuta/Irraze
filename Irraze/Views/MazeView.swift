import SwiftUI

struct MazeView: View {
    @ObservedObject var game: GameModel

    private let fogRadius = 2

    private var shift: Int {
        Grid.cameraShift(row: Grid.row(y: game.myPosition.y), mazeRows: game.maze.rows)
    }

    private var visibleRows: Range<Int> { shift..<shift + Constants.maxRowView }

    var body: some View {
        ZStack {
            ForEach(visibleRows, id: \.self) { row in
                ForEach(0..<game.maze.cols, id: \.self) { col in
                    if isVisible(row: row, col: col) {
                        if game.maze.isWall(row: row, col: col) {
                            Image(systemName: "tree")
                                .foregroundColor(.black)
                                .frame(width: Constants.size, height: Constants.size)
                                .offset(x: Grid.x(col: col), y: Grid.y(row: row - shift))
                        } else if game.maze.isFinish(row: row, col: col) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: Constants.size, height: Constants.size)
                                .offset(x: Grid.x(col: col), y: Grid.y(row: row - shift))
                        }
                    }
                }
            }

            ForEach(game.pickups.filter { visibleRows.contains($0.row) && isVisible(row: $0.row, col: $0.col) }) { pickup in
                Circle()
                    .fill(pickup.skill.color)
                    .frame(width: 12, height: 12)
                    .offset(x: Grid.x(col: pickup.col), y: Grid.y(row: pickup.row - shift))
                    .shadow(radius: 3)
            }

            playerDot(game.myPosition, color: game.myColor)
            if let opponent = game.opponentPosition {
                playerDot(opponent, color: game.opponentColor)
            }
        }
        .frame(width: CGFloat(game.maze.cols) * Constants.step - Constants.spacing,
               height: CGFloat(Constants.maxRowView) * Constants.step - Constants.spacing)
    }

    private func isVisible(row: Int, col: Int) -> Bool {
        guard game.isFogged else { return true }
        let distance = abs(row - Grid.row(y: game.myPosition.y)) + abs(col - Grid.col(x: game.myPosition.x))
        return distance <= fogRadius
    }

    @ViewBuilder
    private func playerDot(_ position: CGPoint, color: Color) -> some View {
        let row = Grid.row(y: position.y)
        if visibleRows.contains(row) {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .offset(x: position.x, y: Grid.y(row: row - shift))
        }
    }
}
