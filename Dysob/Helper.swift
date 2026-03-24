import Foundation

func pixelToRow(pixel: CGFloat, step: CGFloat, max: CGFloat) -> Int {
    return Int((pixel + max) / step)
}

func rowToPixel(row: Int, step: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(row * Int(step) - Int(max))
}
