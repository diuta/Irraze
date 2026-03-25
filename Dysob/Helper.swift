import Foundation

func pixelToCoordinate(pixel: CGFloat, step: CGFloat, max: CGFloat) -> Int {
    return Int((pixel + max) / step)
}

func coordinateToPixel(coordinate: Int, step: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(coordinate * Int(step) - Int(max))
}
