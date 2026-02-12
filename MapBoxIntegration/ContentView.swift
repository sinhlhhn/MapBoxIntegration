//
//  ContentView.swift
//  MapBoxIntegration
//
//  Created by SinhLH.AVI on 11/2/26.
//

import SwiftUI
import MapboxMaps

struct ContentView: View {
    var body: some View {
//        let center = CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0)
        let center = CLLocationCoordinate2D(latitude: 38.8410857803, longitude: -76.9750541388)
        
        MapReader { proxy in
            Map(initialViewport: .camera(center: center, zoom: 10, bearing: 0, pitch: 0)) {
            }
            .onStyleLoaded { _ in
                guard let map = proxy.map else {
                    print("Map is nil")
                    return
                }
                try! spawningMarker(map)
            }
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
    let data = decodeGeoJSON(from: "stations")

    source.data = .featureCollection(data)

    try map.addSource(source)

    try map.addImage(UIImage(named: "pill")!, id: "image id")

    // Add line layer first (so it renders below symbols)
    try map.addLayer(lineLayer())

    // Add symbol layer for points
    try map.addLayer(markerLayer())
}

private func markerLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: "symbol-id", source: "test-data")

    // Render only Point geometries
    layer.filter = Exp(.eq) {
        "$type"
        "Point"
    }

    layer.iconImage = .constant(.name("image id"))
    layer.iconAllowOverlap = .constant(true)
    return layer
}

private func lineLayer() -> LineLayer {
    var layer = LineLayer(id: "line-id", source: "test-data")

    // Render only LineString geometries
    layer.filter = Exp(.eq) {
        "$type"
        "LineString"
    }

    layer.lineColor = .constant(StyleColor(.blue))
    layer.lineWidth = .constant(3.0)
    layer.lineJoin = .constant(.round)
    layer.lineCap = .constant(.round)

    return layer
}

#Preview {
    ContentView()
}
