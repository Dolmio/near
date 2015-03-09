import UIKit

class YellowButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = Colors.yellowBorderColor
    }
}