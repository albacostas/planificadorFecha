import SwiftUI

struct Subcalendar: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var color: RGBAColor = ColorOptions.random().rgbaColor
    var isVisible: Bool = true
}

extension Subcalendar {
    static var example = Subcalendar(title: "Computación Distribuida", color: Color.blue.rgbaColor)
}
