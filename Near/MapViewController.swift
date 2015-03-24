import UIKit
import MapKit
import CoreLocation
import Darwin

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIApplicationDelegate{

    @IBOutlet weak var mapElement: MKMapView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var placeDescription: UILabel!
    let locationManager = CLLocationManager()
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    let userLocationArrowView : MKAnnotationView!
    let placeIconView : MKAnnotationView!
    var currentPlace : Place?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let mapIconWidth = 32
        let  mapIconHeight = 40
        userLocationArrowView = annotationViewWithImage("icon_map_arrow.png", width: mapIconWidth, height: mapIconHeight)
        placeIconView = annotationViewWithImage("icon_map.png", width: mapIconWidth, height: mapIconHeight)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViewWithPlaceFromNotification:", name:"refreshMapView", object: nil);
        mapElement.delegate = self
        if(CLLocationManager.headingAvailable()){
            locationManager.startUpdatingHeading()
        }
        if let place = currentPlace {
            updateMapView(place)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshViewWithPlaceFromNotification(notification:NSNotification) {
        if let userInfo = (notification.userInfo as? Dictionary<String,String>) {
            if let name = userInfo["name"] {
                if let place = PlaceController().fetchPlaceWithName(name){
                    place.visited = true
                    place.lastVisit = NSDate()
                    appDelegate.saveContext()
                    updateMapView(place)
                }
            }
        }
    }

    func updateMapView(place:Place) {
        placeTitle.text = place.name
        placeDescription.text = place.descriptionText
        resetPlaces();
        let placeLocation = CLLocationCoordinate2D(latitude: place.latitude.doubleValue, longitude: place.longitude.doubleValue);
        let mapSizeToRadiusMultiplier = 1.5
        let mapSize = mapSizeToRadiusMultiplier * place.radius.doubleValue * 2
        let mapRegionToShow = MKCoordinateRegionMakeWithDistance(placeLocation, mapSize, mapSize)
        mapElement.setRegion(mapElement.regionThatFits(mapRegionToShow), animated: true)

        let placeAnnotation = MKPointAnnotation()
        placeAnnotation.setCoordinate(placeLocation)
        placeAnnotation.title = "place"
        mapElement.addAnnotation(placeAnnotation)

        let placeCircle = PlaceCircle(centerCoordinate: placeLocation, radius: place.radius.doubleValue)
        mapElement.addOverlay(placeCircle)

        if let userLocation = locationManager.location {
            let userLocationCircle = UserLocationCircle(centerCoordinate: userLocation.coordinate, radius: max(50, userLocation.horizontalAccuracy))
             mapElement.addOverlay(userLocationCircle)
        }
    }

    func resetPlaces() {
        if let annotations = mapElement.annotations {
            for(annotation : MKAnnotation) in annotations as [MKAnnotation]{
                if(annotation.title == "place") {
                    mapElement.removeAnnotation(annotation)
                }
            }
        }

        if let overlays = mapElement.overlays? {
            for(overlay: MKOverlay) in overlays as [MKOverlay] {
                if(overlay is PlaceCircle) {
                    mapElement.removeOverlay(overlay)
                }
            }
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        if(annotation.title == "place") {
            return placeIconView

        }
        else if (annotation is MKUserLocation) {
            return userLocationArrowView
        }
        else{
            return MKPinAnnotationView()
        }
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        switch overlay {
        case is PlaceCircle:
            return createCircleWithOpacity(overlay, opacity: 0.2)
        case is UserLocationCircle:
            return createCircleWithOpacity(overlay, opacity: 0.3)
        default: return nil
        }
    }

    func createCircleWithOpacity(overlay: MKOverlay, opacity: CGFloat) -> MKCircleRenderer {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.fillColor = Colors.yellowMapRadiusColor
        circle.alpha = opacity
        return circle
    }

    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!){
        rotateViewToDegrees(userLocationArrowView, degrees: newHeading.trueHeading)
    }

    func annotationViewWithImage(named: String, width: Int, height: Int) -> MKAnnotationView {
        let annotationView = MKAnnotationView()
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: width, height: height))
        imageView.image = UIImage(named: named)
        let frame = imageView.frame
        annotationView.frame = frame
        imageView.frame = frame
        annotationView.addSubview(imageView)
        return annotationView
    }

    func rotateViewToDegrees(view:UIView, degrees: Double) {
        let radians = degreesToRadians(degrees)
        view.transform = CGAffineTransformMakeRotation(CGFloat(radians))
    }

    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 360.0 * 2 * M_PI
    }


    class PlaceCircle:MKCircle{}
    class UserLocationCircle:MKCircle{}

}

