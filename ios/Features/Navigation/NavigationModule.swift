import Foundation
import heresdk

@objc(NavigationModule)
class NavigationModule: NSObject {
    
    private var visualNavigator: VisualNavigator?
    private var herePositioningProvider: HEREPositioningProvider?
    private var herePositioningSimulator: HEREPositioningSimulator?
    private var routePrefetcher: RoutePrefetcher?
    private var dynamicRoutingEngine: DynamicRoutingEngine?
    private var currentRoute: Route?

    override init() {
        super.init()
        do {
            visualNavigator = try VisualNavigator()
            herePositioningProvider = HEREPositioningProvider()
            herePositioningSimulator = HEREPositioningSimulator()
            routePrefetcher = RoutePrefetcher(SDKNativeEngine.sharedInstance!)
            dynamicRoutingEngine = NavigationModule.createDynamicRoutingEngine()
        } catch let error {
            fatalError("Failed to initialize HERE SDK components. Cause: \(error)")
        }
    }
    
    @objc(startNavigation:withSimulation:withResolver:withRejecter:)
    func startNavigation(
        routeJson: String,
        isSimulated: Bool,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard let routeData = routeJson.data(using: .utf8),
              let route = try? JSONDecoder().decode(Route.self, from: routeData),
              let visualNavigator = visualNavigator else {
            reject("NAVIGATION_ERROR", "Invalid route data", nil)
            return
        }
        
        self.currentRoute = route
        visualNavigator.route = route
        
        let startGeoCoordinates = route.geometry.vertices[0]
        prefetchMapData(currentGeoCoordinates: startGeoCoordinates)

        if isSimulated {
            enableRoutePlayback(route: route)
            resolve("Simulated navigation started.")
        } else {
            enableDevicePositioning()
            resolve("Real navigation started.")
        }

        startDynamicSearchForBetterRoutes(route)
    }
    
    @objc(stopNavigation:withRejecter:)
    func stopNavigation(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard let visualNavigator = visualNavigator else {
            reject("NAVIGATION_ERROR", "VisualNavigator not initialized", nil)
            return
        }
        
        dynamicRoutingEngine?.stop()
        routePrefetcher?.stopPrefetchAroundRoute()
        visualNavigator.route = nil
        enableDevicePositioning()
        
        resolve("Navigation stopped.")
    }
    
    private func enableRoutePlayback(route: Route) {
        herePositioningProvider?.stopLocating()
        herePositioningSimulator?.startLocating(locationDelegate: visualNavigator!, route: route)
    }

    private func enableDevicePositioning() {
        herePositioningSimulator?.stopLocating()
        herePositioningProvider?.startLocating(locationDelegate: visualNavigator!, accuracy: .navigation)
    }

    private func prefetchMapData(currentGeoCoordinates: GeoCoordinates) {
        routePrefetcher?.prefetchAroundLocationWithRadius(currentLocation: currentGeoCoordinates, radiusInMeters: 2000.0)
        routePrefetcher?.prefetchAroundRouteOnIntervals(navigator: visualNavigator!)
    }

    private func startDynamicSearchForBetterRoutes(_ route: Route) {
        do {
            try dynamicRoutingEngine?.start(route: route, delegate: self)
        } catch let error {
            fatalError("Failed to start DynamicRoutingEngine. Cause: \(error)")
        }
    }

    private class func createDynamicRoutingEngine() -> DynamicRoutingEngine? {
        do {
            let options = DynamicRoutingEngineOptions(
                minTimeDifferencePercentage: 0.1,
                minTimeDifference: 1,
                pollInterval: 600 // Poll every 10 minutes
            )
            return try DynamicRoutingEngine(options: options)
        } catch let error {
            fatalError("Failed to initialize DynamicRoutingEngine. Cause: \(error)")
        }
    }
}
