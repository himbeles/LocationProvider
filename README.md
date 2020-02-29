# LocationProvider

A Combine-based CoreLocation provider.

On every update of the device location from a wrapped `CLLocationManager`,
it provides the latest location as a published `CLLocation` object and
via a `PassthroughSubject<CLLocation, Never>` called `locationWillChange`.

## Usage

### Starting the LocationProvider

Initialize and start the LocationProvider

```swift
let locationProvider = LotionProvider()

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

The `requestAuthorization` function accepts a additional closure that handles the  case where access has previously been denied. 

```swift
locationProvider.requestAuthorization(){presentLocationSettingsAlert()}
```
The default action is to present an alert that suggests to go to the app settings screen in order to change the location settings.  

### Handling the Location data

Subscribe to the `locationWillChange` subject and store the returned `Cancellable`

```swift
cancellableLocation = locationProvider.locationWillChange.sink { md in
    // handleLocation(motionData: md)
}
```

The function `handleLocation` in the `sink` closure would be executed on every `CLLocation` object sent by the `LocationProvider`.

Also, the `LocationProvider` is an ObservableObject which has a published property `location` that updates the ObservableObject.
This dynamic property can directly be accessed in SwiftUI.

### Stopping the MotionProvider

Stop the `LocationProvider` and cancel the subscription

```swift
locationProvider.stop()
cancellableLocation?.cancel()
```
