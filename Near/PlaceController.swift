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
        if let name = placeJson["Title"] as? String,
           let category = placeJson["Category"] as? String,
           let description = placeJson["Discription"] as? String,
           let radius = (placeJson["Radius"] as? NSString)?.doubleValue,
           let city = placeJson["City"] as? String,
           let coordinates = (placeJson["Coordinates"] as? NSString)?.componentsSeparatedByString(", "),
           let latitude = (coordinates.first as? NSString)?.doubleValue,
           let longitude = (coordinates[1] as? NSString)?.doubleValue where coordinates.count > 1
        {
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
    
    func saveCityFromObject(cityJson: AnyObject) -> NearCity?{
        if let name = cityJson["Name"] as? String,
           let latitude = (cityJson["Latitude"] as? NSString)?.doubleValue,
           let longitude = (cityJson["Longitude"] as? NSString)?.doubleValue
        {
            let newCity = NSEntityDescription.insertNewObjectForEntityForName("NearCity", inManagedObjectContext: appDelegate.managedObjectContext!) as! NearCity
            newCity.name = name
            newCity.longitude = longitude
            newCity.latitude = latitude
            appDelegate.saveContext()
            return newCity
        } else {
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
            if fetchResults.count > 0 {
                return fetchResults[0]
            }
        }
        return nil
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
            let coords = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            let region = CLCircularRegion(center:coords, radius: place.radius, identifier: place.name)
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
            if let place = fetchPlaceWithName(region.identifier){
                scheduleNotificationForPlace(place)
            }
        }
    }
}
