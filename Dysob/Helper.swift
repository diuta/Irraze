import Foundation

func coordinateToRow(position: CGFloat, step: CGFloat, max: CGFloat) -> Int {
    return Int((position + max) / step)
}

func rowToCoordinate(coordinate: Int, step: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(coordinate * Int(step) - Int(max))
}
