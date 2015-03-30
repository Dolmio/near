import Foundation
import UIKit
import CoreLocation
import CoreData

class PlaceController: NSObject, CLLocationManagerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func readAndPersistPlaces() -> [Place] {
        let path = NSBundle.mainBundle().pathForResource("sample-places-helsinki", ofType: "json")
        let bundle = NSBundle.mainBundle();
        let placeInfoJSONString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        let jsonArray = NSJSONSerialization.JSONObjectWithData(placeInfoJSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as [NSDictionary]
        
        return jsonArray.map(savePlaceFromObject).filter{ $0 != nil }.map{ $0! }
    }

    func savePlaceFromObject(placeJson: AnyObject) -> Place?{
        var longitudeStr: NSString?
        var latitudeStr: NSString?
        if let coordinates = placeJson["Coordinates"] as? NSString {
            let separatedCoords = coordinates.componentsSeparatedByString(", ")
            latitudeStr = separatedCoords.first as? NSString
            longitudeStr = separatedCoords.count > 1 ? (separatedCoords[1] as NSString) : nil
        }
        let name = placeJson["Title"] as? NSString
        let category = placeJson["Category"] as? NSString
        let description = placeJson["Discription"] as? NSString
        let radius = placeJson["Radius"] as? NSString
        switch (name, category, description, radius, longitudeStr, latitudeStr) {
        case (.Some(_), .Some(_), .Some(_), .Some(_), .Some(_), .Some(_)):
            let newPlace = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: appDelegate.managedObjectContext!) as Place
            newPlace.name = name!
            newPlace.category = category!
            newPlace.longitude = longitudeStr!.doubleValue
            newPlace.latitude = latitudeStr!.doubleValue
            newPlace.radius = radius!.doubleValue
            newPlace.descriptionText = description!
            appDelegate.saveContext()
            return newPlace
        default:
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
            return fetchResults[0]
        }
        else{
            return nil
        }
    }

    func fetchVisitedPlaces() -> [Place] {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let predicate = NSPredicate(format: "visited == %@", true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastVisit", ascending: false), NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = predicate
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
            let coords = CLLocationCoordinate2D(latitude: place.latitude.doubleValue, longitude: place.longitude.doubleValue)
            let region = CLCircularRegion(center:coords, radius: place.radius.doubleValue, identifier: place.name)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            return region
        })
        for region in regionsToMonitor {
            locationManager.startMonitoringForRegion(region)
        }
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!){
        let recentLocation = locationManager.location
        let locationAccuracyThreshold = 100.0
        if(recentLocation.horizontalAccuracy <= locationAccuracyThreshold) {
            let placeController = PlaceController()
            if let place = placeController.fetchPlaceWithName(region.identifier){
                placeController.scheduleNotificationForPlace(place)
            }
        }
    }
}
