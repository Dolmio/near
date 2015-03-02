import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIApplicationDelegate{
    
    @IBOutlet weak var mapElement: MKMapView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDescription: UILabel!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for permission for notifications
        let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        // Ask for permission for location
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViewWithPlace:", name:"refreshMapView", object: nil);
        mapElement.delegate = self;

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshViewWithPlace(notification:NSNotification) {
        if let placeDic = notification.userInfo?["place"] as? Dictionary<String, AnyObject> {

            let place = Places.dictionaryToPlace(placeDic);
            refreshMap(place);

            placeTitle.text = place.name;
            placeDescription.text = place.description;
        }

    }

    func refreshMap(place:Place) {
        let placeLocation = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude);
        let spanInDegrees = 0.005;
        let viewRegion = MKCoordinateRegionMake(placeLocation, MKCoordinateSpanMake(spanInDegrees,spanInDegrees));
        mapElement.setRegion(viewRegion, animated: true);

        let placeAnnotation = MKPointAnnotation();
        placeAnnotation.setCoordinate(placeLocation);
        placeAnnotation.title = "place";

        mapElement.addAnnotation(placeAnnotation);
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        if(annotation.title == "place") {
            return annotationViewWithImage("icon_map.png");

        }
        else if (annotation is MKUserLocation) {
            return annotationViewWithImage("icon_map_arrow.png");
        }
        else{
            return MKPinAnnotationView();
        }
    }

    func annotationViewWithImage(named: String) -> MKAnnotationView {
        let annotationView = MKAnnotationView();
        annotationView.image = UIImage(named: named);
        return annotationView;
    }

}
