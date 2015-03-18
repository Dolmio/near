import UIKit
import CoreLocation

class LocationPermissionViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    @IBAction func askLocationPermissions(sender: UIButton) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways{
            performSegue()
        } else {
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
        }
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        performSegue()
    }

    private func performSegue() {
        performSegueWithIdentifier("toNotificationPermissions", sender: self)
    }
}