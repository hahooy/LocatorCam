// OneShotLocationManager - fetches the current device location once and invokes a completion closure
//


import UIKit
import CoreLocation

//possible errors
enum OneShotLocationManagerErrors: Int {
    case authorizationDenied
    case authorizationNotDetermined
    case invalidLocation
}

class OneShotLocationManager: NSObject, CLLocationManagerDelegate {
    
    //location manager
    fileprivate var locationManager: CLLocationManager?
    
    //destroy the manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    typealias LocationClosure = ((_ location: CLLocation?, _ error: NSError?)->())
    fileprivate var didComplete: LocationClosure?

    //location manager returned, call didcomplete closure
    fileprivate func _didComplete(_ location: CLLocation?, error: NSError?) {
        locationManager?.stopUpdatingLocation()
        didComplete?(location, error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    //location authorization status changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            self.locationManager!.startUpdatingLocation()
        case .denied:
            _didComplete(nil, error: NSError(domain: self.classForCoder.description(),
                code: OneShotLocationManagerErrors.authorizationDenied.rawValue,
                userInfo: nil))
        default:
            break
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _didComplete(nil, error: error as NSError?)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        _didComplete(location, error: nil)
    }
    
    //ask for location permissions, fetch 1 location, and return
    func fetchWithCompletion(_ completion: @escaping LocationClosure) {
        //store the completion closure
        didComplete = completion

        //fire the location manager
        locationManager = CLLocationManager()
        locationManager!.delegate = self

        //check for description key and ask permissions
        if (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil) {
            locationManager!.requestWhenInUseAuthorization()
        } else if (Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil) {
            locationManager!.requestAlwaysAuthorization()
        } else {
            fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
        }
        
    }
}
