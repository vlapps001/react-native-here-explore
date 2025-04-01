package com.hereexplore.features.navigation


import android.content.Context
import android.util.Log
import android.widget.TextView
import com.facebook.react.bridge.*
import com.here.sdk.core.GeoCoordinates
import com.here.sdk.core.Location
import com.here.sdk.core.errors.InstantiationErrorException
import com.here.sdk.location.LocationAccuracy
import com.here.sdk.mapview.MapView
import com.here.sdk.navigation.VisualNavigator
import com.here.sdk.prefetcher.RoutePrefetcher
import com.here.sdk.routing.Route
import com.here.sdk.trafficawarenavigation.DynamicRoutingEngine
import com.here.sdk.trafficawarenavigation.DynamicRoutingEngineOptions
import com.here.sdk.trafficawarenavigation.DynamicRoutingListener
import com.here.sdk.routing.RoutingError
import com.here.time.Duration
import com.here.sdk.core.engine.SDKNativeEngine;


class NavigationModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    companion object {
        private const val TAG = "NavigationModule"
    }

    private var visualNavigator: VisualNavigator? = null
    private var routePrefetcher: RoutePrefetcher? = null
    private var dynamicRoutingEngine: DynamicRoutingEngine? = null

    init {
        try {
            visualNavigator = VisualNavigator()
            routePrefetcher = RoutePrefetcher(SDKNativeEngine.getSharedInstance()!!) // Исправлено
            createDynamicRoutingEngine()
        } catch (e: InstantiationErrorException) {
            throw RuntimeException("Initialization failed: ${e.error.name}")
        }
    }

    override fun getName(): String {
        return "NavigationModule"
    }

    @ReactMethod
    fun startNavigation(routeJson: ReadableMap, isSimulated: Boolean, promise: Promise) {
        val route = parseRouteFromJson(routeJson)
        route?.let {
            visualNavigator?.setRoute(it)
            if (isSimulated) {
                enableRoutePlayback(it)
            }
            startDynamicSearchForBetterRoutes(it)
            promise.resolve("Navigation started")
        } ?: promise.reject("ERROR", "Invalid route")
    }

    @ReactMethod
    fun stopNavigation(promise: Promise) {
        visualNavigator?.setRoute(null)
        visualNavigator?.stopRendering()
        dynamicRoutingEngine?.stop()
        routePrefetcher?.stopPrefetchAroundRoute()
        promise.resolve("Navigation stopped")
    }

    private fun startDynamicSearchForBetterRoutes(route: Route) {
        dynamicRoutingEngine?.start(route, object : DynamicRoutingListener {
            override fun onBetterRouteFound(newRoute: Route, etaDifferenceInSeconds: Int, distanceDifferenceInMeters: Int) {
                Log.d(TAG, "New route found: etaDifference: $etaDifferenceInSeconds, distanceDifference: $distanceDifferenceInMeters")
            }

            override fun onRoutingError(routingError: RoutingError) {
                Log.d(TAG, "Routing error: ${routingError.name}")
            }
        })
    }

    private fun createDynamicRoutingEngine() {
        val options = DynamicRoutingEngineOptions().apply {
            minTimeDifference = Duration.ofSeconds(1)
            minTimeDifferencePercentage = 0.1
            pollInterval = Duration.ofMinutes(10)
        }
        try {
            dynamicRoutingEngine = DynamicRoutingEngine(options)
        } catch (e: InstantiationErrorException) {
            throw RuntimeException("DynamicRoutingEngine init failed: ${e.error.name}")
        }
    }

    private fun enableRoutePlayback(route: Route) {
        // Implement route playback logic
    }

    private fun parseRouteFromJson(routeJson: ReadableMap): Route? {
        // Implement JSON parsing logic to convert ReadableMap to Route
        return null
    }
}
