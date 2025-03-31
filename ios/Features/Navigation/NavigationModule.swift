import Foundation
import React
import heresdk
import UIKit

@objc(NavigationModule)
class NavigationModule: NSObject {
    private var mapView: MapView?
    private var routingEngine: RoutingEngine?
    private var visualNavigator: VisualNavigator?
    private var locationSimulator: LocationSimulator?
    private weak var bridge: RCTBridge?

    @objc
    init(bridge: RCTBridge) {
        self.bridge = bridge
        super.init()
        do {
            self.routingEngine = try RoutingEngine()
            self.visualNavigator = try VisualNavigator()
        } catch {
            print("Failed to initialize HERE SDK: \(error)")
        }
    }

    @objc
    func initializeMap(_ reactTag: NSNumber) {
        DispatchQueue.main.async {
            guard let view = self.bridge?.uiManager.view(forReactTag: reactTag) as? UIView else { return }
            self.mapView = MapView(frame: view.bounds)
            if let mapView = self.mapView {
                view.addSubview(mapView)
                mapView.mapScene.loadScene(mapScheme: .normalDay) { error in
                    if let error = error {
                        print("Error loading map scene: \(error)")
                    }
                }
            }
        }
    }

    @objc
    func startNavigation(_ startLat: Double, startLng: Double, destLat: Double, destLng: Double) {
        guard let routingEngine = self.routingEngine else { return }

        let startWaypoint = Waypoint(coordinates: GeoCoordinates(latitude: startLat, longitude: startLng))
        let destinationWaypoint = Waypoint(coordinates: GeoCoordinates(latitude: destLat, longitude: destLng))

        routingEngine.calculateRoute(with: [startWaypoint, destinationWaypoint], carOptions: CarOptions()) { error, routes in
            if let error = error {
                print("Routing error: \(error)")
                return
            }
            if let route = routes?.first {
                self.startTurnByTurnNavigation(route: route)
            }
        }
    }

    private func startTurnByTurnNavigation(route: Route) {
        guard let mapView = self.mapView, let visualNavigator = self.visualNavigator else { return }

        visualNavigator.startRendering(mapView: mapView)
        visualNavigator.route = route

        do {
            self.locationSimulator = try LocationSimulator(route: route, options: LocationSimulatorOptions())
            self.locationSimulator?.delegate = visualNavigator
            self.locationSimulator?.start()
        } catch {
            print("Failed to initialize LocationSimulator: \(error)")
        }
    }

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
}
