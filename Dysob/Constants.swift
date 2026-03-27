import Foundation
import SwiftUI

public enum Constants {
    static let size: CGFloat = 25
    static let spacing: CGFloat = 5
    static let rows: Int = 51
    static let cols: Int = 11
    static let maxRowView: Int = 10
    static let cameraBoundary: Int = 5
    
    static var step: CGFloat { spacing + size }
    static var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    static var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }
    
    static let bodyColor = Color(red: 121/255, green: 186/255, blue: 170/255)
    static let secondaryBodyColor = Color(red: 101/255, green: 166/255, blue: 150/255)
    static let screenColor = Color(red: 198, green: 227, blue: 189)
}
