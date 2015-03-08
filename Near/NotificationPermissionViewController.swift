import UIKit

class NotificationPermissionViewController: UIViewController, UIApplicationDelegate {
    @IBAction func askNotificationPermissions(sender: UIButton) {
        let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        let notificationsAllowed = (notificationSettings.types & UIUserNotificationType.Alert) != nil

        if notificationsAllowed {
            performSegue()
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationsRegistered:", name:"notificationSettingsRegistered", object: nil);
            let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }

    func notificationsRegistered(notification: NSNotification) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userHasSeenIntroduction")
        performSegue()
    }

    private func performSegue() {
        performSegueWithIdentifier("toMain", sender: self)
    }
}