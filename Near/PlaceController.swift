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

    func readJSON(from: String) -> [NSDictionary] {
        let path = NSBundle.mainBundle().pathForResource(from, ofType: "json")
        let bundle = NSBundle.mainBundle();
        let infoJSONString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        let jsonArray = NSJSONSerialization.JSONObjectWithData(infoJSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! [NSDictionary]
        return jsonArray
    }
    
    func readAndPersistPlaces() -> [Place] {
        let jsonArray = readJSON("sample-places-helsinki")
        
        return jsonArray.map(savePlaceFromObject).filter{ $0 != nil }.map{ $0! }
    }
    
    func readAndPersistCities() -> [NearCity] {
        let jsonArray = readJSON("sample-cities")
        
        return jsonArray.map(saveCityFromObject).filter{ $0 != nil }.map{ $0! }
    }

    func savePlaceFromObject(placeJson: AnyObject) -> Place?{
        var longitudeStr: NSString?
        var latitudeStr: NSString?
        if let coordinates = placeJson["Coordinates"] as? NSString {
            let separatedCoords = coordinates.componentsSeparatedByString(", ")
            latitudeStr = separatedCoords.first as? NSString
            longitudeStr = separatedCoords.count > 1 ? (separatedCoords[1] as! NSString) : nil
        }
        let name = placeJson["Title"] as? NSString
        let city = placeJson["City"] as? NSString
        let category = placeJson["Category"] as? NSString
        let description = placeJson["Discription"] as? NSString
        let radius = placeJson["Radius"] as? NSString
        switch (name, category, description, radius, longitudeStr, latitudeStr, city) {
        case (.Some(_), .Some(_), .Some(_), .Some(_), .Some(_), .Some(_), .Some(_)):
            let newPlace = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: appDelegate.managedObjectContext!) as! Place
            newPlace.name = name! as String
            newPlace.city = city! as String
            newPlace.category = category! as String
            newPlace.longitude = longitudeStr!.doubleValue
            newPlace.latitude = latitudeStr!.doubleValue
            newPlace.radius = radius!.doubleValue
            newPlace.descriptionText = description! as String
            appDelegate.saveContext()
            return newPlace
        default:
            println("Skipping place because format was invalid: ", placeJson)
            return nil
        }
    }
    
    func saveCityFromObject(cityJson: AnyObject) -> NearCity?{
        let name = cityJson["Name"] as? NSString
        let latitude = cityJson["Latitude"] as? NSString
        let longitude = cityJson["Longitude"] as? NSString
        switch (name, latitude, longitude) {
        case (.Some(_), .Some(_), .Some(_)):
            let newCity = NSEntityDescription.insertNewObjectForEntityForName("NearCity", inManagedObjectContext: appDelegate.managedObjectContext!) as! NearCity
            newCity.name = name! as String
            newCity.longitude = longitude!.doubleValue
            newCity.latitude = latitude!.doubleValue
            appDelegate.saveContext()
            return newCity
        default:
            println("Skipping city because format was invalid: ", cityJson)
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
    
    func fetchPlacesWithinCity(city: String) -> [Place] {
        let fetchRequest = NSFetchRequest(entityName: "Place")
        let predicate = NSPredicate(format: "city == %@", city)
        fetchRequest.predicate = predicate
        var maybeError: NSError?
        if let fetchResults = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &maybeError) as? [Place] {
            return fetchResults
        }
        else if let error = maybeError {
            println("Error fetching places within city: \(error.localizedDescription)")
            return []
        }
        else{
            return []
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
    
    func fetchAllCities() -> [NearCity] {
        let fetchRequest = NSFetchRequest(entityName: "NearCity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var maybeError: NSError?
        if let fetchResults = appDelegate.managedObjectContext!.executeFetchRequest(fetchRequest, error: &maybeError) as? [NearCity] {
            return fetchResults
        }
        else if let error = maybeError{
            println("Error fetching cities: \(error.localizedDescription)")
            return []
        }else{
            return []
        }
    }
    
    func setupPlacesAndRegions() {
        let places = readAndPersistPlaces()
        let cities = readAndPersistCities()
        changeMonitoredRegionsToNearestCity()
    }
    
    func changeRegions(cityName: String) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let places = fetchPlacesWithinCity(cityName)
        let regionsToMonitor = places.map({(place) -> CLRegion in
            let coords = CLLocationCoordinate2D(latitude: place.latitude.doubleValue, longitude: place.longitude.doubleValue)
            let region = CLCircularRegion(center:coords, radius: place.radius.doubleValue, identifier: place.name)
            region.notifyOnEntry = true
            region.notifyOnExit = false
            return region
        })
        for region in regionsToMonitor {
            println("Added region \(region.identifier)")
            locationManager.startMonitoringForRegion(region)
        }
    }
    
    func changeMonitoredRegionsToNearestCity() {
        var cities = fetchAllCities()
        var recentLocation = locationManager.location
        if (recentLocation == nil) {
            //Set up Helsinki as the default location
            recentLocation = CLLocation(latitude: 60.170833, longitude: 24.9375)
        }
        
        cities.sort {
            let city1Loc = CLLocation(latitude: $0.latitude.doubleValue, longitude: $0.longitude.doubleValue)
            let city2Loc = CLLocation(latitude: $1.latitude.doubleValue, longitude: $1.longitude.doubleValue)
            let city1Dist = recentLocation.distanceFromLocation(city1Loc)
            let city2Dist = recentLocation.distanceFromLocation(city2Loc)
            return city1Dist < city2Dist
        }
        changeRegions(cities[0].name)
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        changeMonitoredRegionsToNearestCity()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
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
