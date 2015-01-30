import Foundation
import SwiftyJSON
import CoreLocation

struct Places{
    static func initialPlaces() -> [Place] {
        let path = NSBundle.mainBundle().pathForResource("sample-places-helsinki", ofType: "json")
        let bundle = NSBundle.mainBundle();
        let placeInfoJSONString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        let json = JSON(data: placeInfoJSONString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!);
        
        var places: [Place] = []
        for (index: String, placeJson: JSON) in json {
            let coordinates = placeJson["Coordinates"].string!.componentsSeparatedByString(", ")
            let longitudeStr: String? = coordinates.count > 1 ? coordinates[1] : nil
            let name = placeJson["Title"].string
            let category = placeJson["Category"].string
            let description = placeJson["Discription"].string
            let radius = placeJson["Radius"].string
            switch (name, category, description, radius, longitudeStr){
                case (.Some(_), .Some(_), .Some(_), .Some(_), .Some(_)):
                
                let place = Place(
                    name: name!,
                    category: category!,
                    latitude: (coordinates[0] as NSString).doubleValue,
                    longitude: (longitudeStr! as NSString).doubleValue,
                    description: description!,
                    radius: (radius! as NSString).doubleValue)
                
                places.append(place)

            default:
                println("Skipping place because format was invalid: ", placeJson)
            }
        }
        return places
    }
    
    static func notificationsForPlaces(places : [Place]) -> [UILocalNotification] {
        return places.map({ (place: Place) -> UILocalNotification in
            let notification = UILocalNotification()
            notification.alertBody = "You're near \(place.name)"
            let coords = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            notification.region = CLCircularRegion(center: coords, radius: place.radius, identifier: place.name)
            notification.regionTriggersOnce = false
            return notification
        })
    }
    
    static func registerNotifications(notifications:[UILocalNotification]) {
        let sharedApplication = UIApplication.sharedApplication()
        for (placeNotification: UILocalNotification) in notifications{
            sharedApplication.scheduleLocalNotification(placeNotification)
        }
    }
    
    static func setupInitialPlaceNotifications() {
        let notifications = notificationsForPlaces(initialPlaces())
        registerNotifications(notifications)
    }
}

struct Place {
    let name: String
    let category: String
    let latitude: Double
    let longitude: Double
    let description: String
    let radius: Double
}




    
