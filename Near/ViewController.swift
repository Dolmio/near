import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ask for permission for notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Ask for permission for location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
     
        let notification = UILocalNotification()
        notification.alertBody = "You're nearly there!"
        let coords = CLLocationCoordinate2D(latitude: 60.186207, longitude: 24.827195)
        notification.region = CLCircularRegion(center: coords, radius: 50, identifier: "Destination")
        notification.regionTriggersOnce = false
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
