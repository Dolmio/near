import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIApplicationDelegate{
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for permission for notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Ask for permission for location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        //Before accepting permission to show notifications this code is run while the permission dialog is visible to the user
        let currentNotificationPermissions = UIApplication.sharedApplication().currentUserNotificationSettings()
        if(currentNotificationPermissions.types == UIUserNotificationType.Alert) {
                Places.setupInitialPlaceNotifications()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
