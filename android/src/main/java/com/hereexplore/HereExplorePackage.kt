package com.hereexplore

import android.view.ViewGroup
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewGroupManager
import com.hereexplore.features.map.MapsViewManager
import com.hereexplore.features.arrow.ArrowViewManager
import com.hereexplore.features.marker.MarkerViewManager
import com.hereexplore.features.polygon.PolygonViewManager
import com.hereexplore.features.polyline.PolylineViewManager
import com.hereexplore.features.config.ConfigModule
import com.hereexplore.features.pin.PinViewContentManager
import com.hereexplore.features.pin.PinViewManager
import com.hereexplore.features.routing.RoutingModule
import com.hereexplore.features.navigation.NavigationModule

class HereExplorePackage : ReactPackage {

  override fun createViewManagers(reactContext: ReactApplicationContext): ArrayList<ViewGroupManager<out ViewGroup>> {
    return arrayListOf(
      MapsViewManager(),
      ArrowViewManager(),
      PolygonViewManager(),
      PolylineViewManager(),
      MarkerViewManager(),
      PinViewManager(),
      PinViewContentManager()
    )
  }

  override fun createNativeModules(reactContext: ReactApplicationContext): MutableList<NativeModule> {
    return arrayListOf(
      RoutingModule(reactContext),
      ConfigModule(reactContext),
      NavigationModule(reactContext)
    )
  }
}
