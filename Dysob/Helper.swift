import Foundation

//func pixelToCoordinate(pixel: CGFloat, step: CGFloat, max: CGFloat) -> Int {
//    return Int((pixel + max) / step)
//}
//
//func coordinateToPixel(coordinate: Int, step: CGFloat, max: CGFloat) -> CGFloat {
//    return CGFloat(coordinate * Int(step) - Int(max))
//}

func pixelToRow(pixel: CGFloat) -> Int {
    return Int((pixel + Constants.maxX) / Constants.step)
}

func pixelToCol(pixel: CGFloat) -> Int {
    return Int((pixel + Constants.maxX) / Constants.step)
}

func rowToPixel(row: Int) -> CGFloat {
    return CGFloat(row * Int(Constants.step) - Int(Constants.maxX))
}

func colToPixel(col: Int) -> CGFloat {
    return CGFloat(col * Int(Constants.step) - Int(Constants.maxY))
}
