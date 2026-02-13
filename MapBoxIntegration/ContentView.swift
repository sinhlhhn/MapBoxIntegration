//
//  ContentView.swift
//  MapBoxIntegration
//
//  Created by SinhLH.AVI on 11/2/26.
//

import SwiftUI
import MapboxMaps

struct Waypoint: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let frequency: String?
    let elevation: Int?
}

struct ContentView: View {
    
    @State private var selectedWaypoint: Waypoint?
    
    var body: some View {
//        let center = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0)
        let center = CLLocationCoordinate2D(latitude: 14.508647, longitude: 121.019581)
        
        MapReader { proxy in
            Map(initialViewport: .camera(center: center, zoom: 5, bearing: 0, pitch: 0))
            {
                handleTapInteraction(for: "symbol-id")
                handleTapInteraction(for: "Point_departure-symbol-id")
                handleTapInteraction(for: "Point_destination-symbol-id")
                
                if let waypoint = selectedWaypoint {
                        MapViewAnnotation(coordinate: waypoint.coordinate) {
                            WaypointInfoCard(waypoint: waypoint) {
                                selectedWaypoint = nil
                            }
                        }
                        .allowOverlap(true)
                    }
            }
            .ornamentOptions(OrnamentOptions(scaleBar: ScaleBarViewOptions(position: .bottomLeading)))
//            .mapStyle(MapStyle(uri: .init(rawValue: "mapbox://styles/thaohus/cmlj09vt0004d01r8g0cg6kvp")!))
            .onStyleLoaded { _ in
                guard let map = proxy.map else {
                    print("Map is nil")
                    return
                }
                try! spawningMarker(map)
            }
        }
    }
    
    private func handleTapInteraction(for layer: String) -> TapInteraction {
        TapInteraction(.layer(layer)) { feature, context in
            print("======= \(feature.properties)")
            let properties = feature.properties
            let geometry = feature.geometry
            
            guard case let .string(name)? = properties["name"],
                  case let .point(point) = geometry
            else {
                selectedWaypoint = nil
                return false
            }
            
            selectedWaypoint = Waypoint(
                id: feature.id?.id ?? UUID().uuidString,
                name: name,
                coordinate: CLLocationCoordinate2D(
                    latitude: point.coordinates.latitude,
                    longitude: point.coordinates.longitude
                ),
                frequency: nil,
                elevation: nil
            )
            return true
        }
    }
    
    
}

private func decodeGeoJSON(from fileName: String) -> FeatureCollection {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "geojson") else {
        preconditionFailure("File '\(fileName)' not found.")
    }

    let filePath = URL(fileURLWithPath: path)
    var featureCollection: FeatureCollection
    do {
        let data = try Data(contentsOf: filePath)
        featureCollection = try JSONDecoder().decode(FeatureCollection.self, from: data)
    } catch {
        print("Error parsing data: \(error)")
        featureCollection = FeatureCollection(features: [])
    }

    return featureCollection
}

private func spawningMarker(_ map: MapboxMap) throws {
    var source = GeoJSONSource(id: "test-data")
    let data = decodeGeoJSON(from: "waypoints")

    source.data = .featureCollection(data)

    try map.addSource(source)

    try map.addImage(UIImage(named: "pill")!, id: "image id")
    try map.addImage(UIImage(named: "circle")!, id: "circle")

    // Add line layer first (so it renders below symbols)
    try map.addLayer(flightPathLayer())
    try map.addLayer(routeLineLayer())

    // Add symbol layer for points
    try map.addLayer(markerLayer())
    try map.addLayer(departureCircleLayer())
    try map.addLayer(destinationCircleLayer())
}

private func markerLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: "symbol-id", source: "test-data")

    // Render only Point geometries
    layer.filter = Exp(.eq) {
        Exp(.get) { "type" }
        "waypoint"
    }

    layer.iconImage = .constant(.name("image id"))
    layer.iconAllowOverlap = .constant(true)
    
    layer.textSize = .constant(12)
    layer.textColor = .constant(StyleColor(.white))
    layer.textHaloColor = .constant(StyleColor(.black))
    layer.textHaloWidth = .constant(1.5)
    layer.textAnchor = .constant(.top)
    layer.textOffset = .constant([0, 1.2])
    layer.textAllowOverlap = .constant(true)
    
    return layer
}

private func departureCircleLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: "Point_departure-symbol-id", source: "test-data")

    // Render only Point geometries
    layer.filter = Exp(.eq) {
        Exp(.get) { "type" }
        "departure"
    }

    layer.iconImage = .constant(.name("circle"))
    layer.iconAllowOverlap = .constant(true)
    return layer
}

private func destinationCircleLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: "Point_destination-symbol-id", source: "test-data")

    // Render only Point geometries
    layer.filter = Exp(.eq) {
        Exp(.get) { "type" }
        "destination"
    }

    layer.iconImage = .constant(.name("circle"))
    layer.iconAllowOverlap = .constant(true)
    return layer
}

private func flightPathLayer() -> LineLayer {
    var layer = LineLayer(id: "flight_path", source: "test-data")

    // Render only LineString geometries
    layer.filter = Exp(.eq) {
        Exp(.get) { "type" }
        "flight_path"
    }

    layer.lineColor = .constant(StyleColor(.blue))
    layer.lineWidth = .constant(3.0)
    layer.lineJoin = .constant(.round)
    layer.lineCap = .constant(.round)

    return layer
}

private func routeLineLayer() -> LineLayer {
    var layer = LineLayer(id: "route_line", source: "test-data")

    // Render only LineString geometries
    layer.filter = Exp(.eq) {
        Exp(.get) { "type" }
        "route_line"
    }

    layer.lineColor = .constant(StyleColor(.yellow))
    layer.lineWidth = .constant(3.0)
    layer.lineJoin = .constant(.round)
    layer.lineCap = .constant(.round)

    return layer
}

#Preview {
    ContentView()
}
