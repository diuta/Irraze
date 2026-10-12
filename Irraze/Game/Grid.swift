import CoreGraphics

enum Grid {
    static func row(y: CGFloat) -> Int { Int((y + Constants.maxY) / Constants.step) }
    static func col(x: CGFloat) -> Int { Int((x + Constants.maxX) / Constants.step) }
    static func y(row: Int) -> CGFloat { CGFloat(row * Int(Constants.step) - Int(Constants.maxY)) }
    static func x(col: Int) -> CGFloat { CGFloat(col * Int(Constants.step) - Int(Constants.maxX)) }

    static func cameraShift(row: Int, mazeRows: Int) -> Int {
        min(max(row - Constants.cameraBoundary, 0), mazeRows - Constants.maxRowView)
    }
}
