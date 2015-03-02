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

        let placeCircle = PlaceCircle(centerCoordinate: placeLocation, radius: place.radius);
        mapElement.addOverlay(placeCircle);

        if let userLocation = locationManager.location {
            let userLocationCircle = UserLocationCircle(centerCoordinate: userLocation.coordinate, radius: 50);
             mapElement.addOverlay(userLocationCircle);
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        let width = 32;
        let height = 40;
        if(annotation.title == "place") {
            return annotationViewWithImage("icon_map.png", width: width, height: height);

        }
        else if (annotation is MKUserLocation) {
            return annotationViewWithImage("icon_map_arrow.png", width: width, height: height);
        }
        else{
            return MKPinAnnotationView();
        }
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        switch overlay {
        case is PlaceCircle:
            return createCircleWithOpacity(overlay, opacity: 0.2);
        case is UserLocationCircle:
            return createCircleWithOpacity(overlay, opacity: 0.3);
        default: return nil;
        }
    }

    func createCircleWithOpacity(overlay: MKOverlay, opacity: CGFloat) -> MKCircleRenderer {
        let circle = MKCircleRenderer(overlay: overlay);
        circle.fillColor = Colors.yellowMapRadiusColor;
        circle.alpha = opacity;
        return circle;
    }

    func annotationViewWithImage(named: String, width: Int, height: Int) -> MKAnnotationView {
        let annotationView = MKAnnotationView();
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: width, height: height));
        imageView.image = UIImage(named: named);
        let frame = imageView.frame;
        annotationView.frame = frame;
        imageView.frame = frame;
        annotationView.addSubview(imageView);
        return annotationView;
    }

    class PlaceCircle:MKCircle{}
    class UserLocationCircle:MKCircle{}

}
