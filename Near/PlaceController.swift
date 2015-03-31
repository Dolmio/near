import Foundation
import UIKit
import CoreLocation
import CoreData

class PlaceController: NSObject, CLLocationManagerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func readAndPersistPlaces() -> [Place] {
        let path = NSBundle.mainBundle().pathForResource("sample-places-helsinki", ofType: "json")
        let bundle = NSBundle.mainBundle();
        let placeInfoJSONString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        let jsonArray = NSJSONSerialization.JSONObjectWithData(placeInfoJSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! [NSDictionary]
        
        return jsonArray.map(savePlaceFromObject).filter{ $0 != nil }.map{ $0! }
    }

    func savePlaceFromObject(placeJson: AnyObject) -> Place?{
        if let name = placeJson["Title"] as? String,
            let category = placeJson["Category"] as? String,
            let description = placeJson["Discription"] as? String,
            let radius = (placeJson["Radius"] as? NSString)?.doubleValue,
            let city = placeJson["City"] as? String,
            let coordinates = (placeJson["Coordinates"] as? NSString)?.componentsSeparatedByString(", "),
            let latitude = (coordinates.first as? NSString)?.doubleValue,
            let longitude = (coordinates[1] as? NSString)?.doubleValue where coordinates.count > 1 {
            let newPlace = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: appDelegate.managedObjectContext!) as! Place
            newPlace.name = name
            newPlace.category = category
            newPlace.longitude = longitude
            newPlace.latitude = latitude
            newPlace.radius = radius
            newPlace.descriptionText = description
            newPlace.city = city
            appDelegate.saveContext()
            return newPlace
        } else {
            println("Skipping place because format was invalid: ", placeJson)
            return nil
        }
    }

    func scheduleNotificationForPlace(place: Place){
        let notification = UILocalNotification()
        notification.alertBody = "You're near \(place.name)"
        notification.fireDate = NSDate(timeIntervalSinceNow: 0)
        notification.userInfo = ["name": place.name]
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func fetchPlaceWithName(name: String) -> Place? {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        fetchRequest.fetchLimit = 1
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        if let fetchResults = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Place] {
            if fetchResults.count > 0 {
                return fetchResults[0]
            }
        }
        return nil
    }

    static func visitedPlacesRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        fetchRequest.predicate = NSPredicate(format: "visited == %@", true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastVisit", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }

    func fetchVisitedPlaces() -> [Place] {
        var maybeError: NSError?
        if let fetchResults = appDelegate.managedObjectContext!.executeFetchRequest(PlaceController.visitedPlacesRequest(), error: &maybeError) as? [Place] {
            return fetchResults
        }
        else if let error = maybeError{
            println("Error fetching visted places: \(error.localizedDescription)")
            return []
        }else{
            return []
        }
    }

    func fetchAllPlaces() -> [Place] {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastVisit", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        var maybeError: NSError?
        if let fetchResults = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &maybeError) as? [Place] {
            return fetchResults
        }
        else if let error = maybeError{
            println("Error fetching visted places: \(error.localizedDescription)")
            return []
        }else{
            return []
        }
    }
    
    func setupPlacesAndRegions() {
        let places = readAndPersistPlaces()
        let regionsToMonitor = places.map({(place) -> CLRegion in
            let coords = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center:coords, radius: place.radius, identifier: place.name)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            return region
        })
        for region in regionsToMonitor {
            locationManager.startMonitoringForRegion(region)
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let recentLocation = locationManager.location
        var berlin = CLLocation(latitude: 52.523333, longitude: 13.411389)
        var helsinki = CLLocation(latitude: 60.170833, longitude: 24.9375)
        var london = CLLocation(latitude: 51.507222, longitude: 0.1275)
        if (recentLocation.distanceFromLocation(berlin) <= 250000) {
            println("in berlin")
        } else if (recentLocation.distanceFromLocation(helsinki) <= 105000) {
            println("in helsinki")
        } else if (recentLocation.distanceFromLocation(london) <= 750000) {
            println("in london")
        }
        println(recentLocation)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!){
        let recentLocation = locationManager.location
        let locationAccuracyThreshold = 100.0
        if(recentLocation.horizontalAccuracy <= locationAccuracyThreshold) {
            if let place = fetchPlaceWithName(region.identifier){
                scheduleNotificationForPlace(place)
            }
        }
    }
}
