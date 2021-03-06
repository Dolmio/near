import UIKit

class NotificationPermissionViewController: UIViewController, UIApplicationDelegate {
    @IBAction func askNotificationPermissions(sender: UIButton) {
        let requiredNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        let notificationsAllowed = (notificationSettings.types & requiredNotificationTypes) != nil

        if notificationsAllowed {
            performSegue()
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationsRegistered:", name:"notificationSettingsRegistered", object: nil);
            let notificationSettings = UIUserNotificationSettings(forTypes: requiredNotificationTypes, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }

    func notificationsRegistered(notification: NSNotification) {
        performSegue()
    }

    private func performSegue() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userHasSeenIntroduction")
        performSegueWithIdentifier("toMain", sender: self)
    }
}