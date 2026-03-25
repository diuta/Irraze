import Foundation

func pixelToRow(pixel: CGFloat) -> Int {
    return Int((pixel + Constants.maxY) / Constants.step)
}

func pixelToCol(pixel: CGFloat) -> Int {
    return Int((pixel + Constants.maxX) / Constants.step)
}

func rowToPixel(row: Int) -> CGFloat {
    return CGFloat(row * Int(Constants.step) - Int(Constants.maxY))
}

func colToPixel(col: Int) -> CGFloat {
    return CGFloat(col * Int(Constants.step) - Int(Constants.maxX))
}
