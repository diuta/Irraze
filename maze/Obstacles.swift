// Obstacles.swift
import SwiftUI

struct Obstacles: View {
    let maze: MazeGenerator
    let size: CGFloat
    let spacing: CGFloat

    private var step: CGFloat { size + spacing }

    var body: some View {
        ZStack {
            ForEach(0..<maze.rows, id: \.self) { row in
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
        let maxY = CGFloat(maze.rows - 1) / 2 * step
        let x = CGFloat(col) * step - maxX
        let y = CGFloat(row) * step - maxY

        return Image(systemName: "tree.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.8, height: size * 0.8)
            .foregroundColor(.green)
            .position(x: x + size / 2, y: y + size / 2)  // align to grid origin
            .offset(x: size / 2, y: size / 2)             // center within tile
    }
}
