import WatchKit
import Foundation

extension WKPickerItem {
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
