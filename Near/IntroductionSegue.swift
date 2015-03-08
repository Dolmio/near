import UIKit

class IntroductionSegue: UIStoryboardSegue {
    override func perform() {
        var source = self.sourceViewController as UIViewController
        var destination = self.destinationViewController as UIViewController

        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade

        source.view.window?.layer.addAnimation(transition, forKey: kCATransitionFade)
        source.presentViewController(destination, animated: false, completion: nil)
    }
}