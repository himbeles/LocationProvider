//
//  LocationProvider.swift
//
//  Created by Luis R on 27.11.19.
//  Copyright © 2019 himbeles. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import UIKit

/**
 A Combine-based CoreLocation provider.
 
 On every update of the device location from a wrapped `CLLocationManager`,
 it provides the latest location as a published `CLLocation` object and
 via a `PassthroughSubject<CLLocation, Never>` called `locationWillChange`.
 */
public class LocationProvider: NSObject, ObservableObject {
    
    private let lm = CLLocationManager()
    
    /// Is emitted when the `location` property changes.
    public let locationWillChange = PassthroughSubject<CLLocation, Never>()
    
    /**
     The latest location provided by the `CLLocationManager`.
     
     Updates of its value trigger both the `objectWillChange` and the `locationWillChange` PassthroughSubjects.
     */
    @Published public private(set) var location: CLLocation? {
        willSet {
            locationWillChange.send(newValue ?? CLLocation())
        }
    }
    
    /// The authorization status for CoreLocation.
    @Published public var authorizationStatus: CLAuthorizationStatus?
    
    public override init() {
        super.init()
        
        self.lm.delegate = self
        self.lm.desiredAccuracy = kCLLocationAccuracyBest
        self.lm.requestWhenInUseAuthorization()
        
        self.lm.activityType = .fitness
        self.lm.distanceFilter = 10
        self.lm.allowsBackgroundLocationUpdates = true
        self.lm.pausesLocationUpdatesAutomatically = false
        self.lm.showsBackgroundLocationIndicator = true
    }
    
    /**
     Request location access from user.
     
     In case, the access has already been denied, execute the `onAuthorizationDenied` closure.
     The default behavior is to present an alert that suggests going to the settings page.
     */
    public func requestAuthorization(onAuthorizationDenied : ()->Void = {presentLocationSettingsAlert()}) -> Void {
        if self.authorizationStatus == CLAuthorizationStatus.denied {
            onAuthorizationDenied()
        }
        else {
            self.lm.requestWhenInUseAuthorization()
        }
    }
    
    /// Start the Location Provider.
    public func start() throws -> Void {
        guard self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways else {
            throw LocationProviderError.noAuthorization
        }
        self.lm.startUpdatingLocation()
    }
    
    /// Stop the Location Provider.
    public func stop() -> Void {
        self.lm.stopUpdatingLocation()
    }
    
}

/// Present an alert that suggests to go to the app settings screen.
public func presentLocationSettingsAlert(alertText : String? = nil) -> Void {
    let alertController = UIAlertController (title: "Enable Location Access", message: alertText ?? "The location access for this app is set to 'never'. Enable location access in the application settings. Go to Settings now?", preferredStyle: .alert)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
        guard let settingsUrl = URL(string:UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
}


/// Error which is thrown for lacking localization authorization.
public enum LocationProviderError: Error {
    case noAuthorization
}

extension LocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
}
