# LocationProvider

A Combine-based CoreLocation provider.

On every update of the device location from a wrapped `CLLocationManager`,
it provides the latest location as a published `CLLocation` object and
via a `PassthroughSubject<CLLocation, Never>` called `locationWillChange`.

## Usage

### Starting the LocationProvider

Initialize and start the LocationProvider

```swift
import LocationProvider

let locationProvider = LocationProvider()

do {
    try locationProvider.start()
}
catch LocationProviderError.noAuthorization {
    // handle the lack of authorization, e.g. by
    // locationProvider.requestAuthorization()
}
catch {
    print("Unexpected error: \(error).")
}
```

Potential location access authorization errors `LocationProviderError.noAuthorization` need to be caught.


### Requesting Location Access

The standard location access user dialog can be brought up via
```swift
locationProvider.requestAuthorization()
```

The `LocationProvider` has a property `onAuthorizationStatusDenied` that defines an action to be executed in case where location access is currently denied. 
The default action is to present an alert (`presentLocationSettingsAlert()`) that suggests to go to the app settings screen in order to change the location settings.  

### Handling the Location data

Subscribe to the `locationWillChange` subject and store the returned `Cancellable`

```swift
cancellableLocation = locationProvider.locationWillChange.sink { loc in
    // handleLocation(loc)
}
```

The function `handleLocation` in the `sink` closure would be executed on every `CLLocation` object sent by the `LocationProvider`.

Also, the `LocationProvider` is an ObservableObject which has a `@Published` property `location` that updates the ObservableObject.
The observable `LocationProvider` and its `location` property can directly be accessed in SwiftUI:

```swift
import SwiftUI
import LocationProvider

struct ContentView: View {
    @ObservedObject var locationProvider : LocationProvider
    
    init() {
        locationProvider = LocationProvider()
        do {try locationProvider.start()} catch(LocationProviderError.noAuthorization) {
            print("no access")
            locationProvider.requestAuthorization()
        } catch {print("did not start")}
    }

    var body: some View {
        VStack{
        Text("latitude \(locationProvider.location?.coordinate.latitude ?? 0)")
        Text("longitude \(locationProvider.location?.coordinate.longitude ?? 0)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```



### Stopping the MotionProvider

Stop the `LocationProvider` and cancel the subscription

```swift
locationProvider.stop()
cancellableLocation?.cancel()
```

### Set correct properties in Info.plist

In order for the app to have access to user location, the following keys should be set in `Info.plist`:

* `NSLocationAlwaysAndWhenInUseUsageDescription`
* `NSLocationAlwaysUsageDescription`
* `NSLocationWhenInUseUsageDescription`

If location access in the background is required, add `Location` to `UIBackgroundModes`.
