//
//  WaypointInfoCard.swift
//  MapBoxIntegration
//
//  Created by SinhLH.AVI on 12/2/26.
//

import SwiftUI

struct WaypointInfoCard: View {

    let waypoint: Waypoint
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(waypoint.name)
                    .font(.headline)

                Spacer()

                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }

            if let frequency = waypoint.frequency {
                Text("Freq: \(frequency)")
                    .font(.subheadline)
            }

            if let elevation = waypoint.elevation {
                Text("Elev: \(elevation) ft")
                    .font(.subheadline)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 6)
        .frame(width: 220)
    }
}

#Preview {
    WaypointInfoCard(waypoint: .init(id: "", name: "", coordinate: .init(latitude: 1, longitude: 1), frequency: nil, elevation: nil) , onClose: {}
    )
}
