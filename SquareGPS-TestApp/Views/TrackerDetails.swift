import SwiftUI
import SwiftData
import MapKit

struct TrackerDetails: View {
    
    var tracker: TrackerData
    
    var mainData: [(String, String)] {
        var data = [
            ("ID:", "\(tracker.id)"),
            ("Model", "\(tracker.source.model)"),
            ("Group ID:", "\(tracker.groupId)"),
        ]
        if let phone = tracker.phone {
            data.append(("Phone:", "\(phone)"))
        }
        if let state = tracker.state {
            data.append(("Latitude:", "\(state.lat)"))
            data.append(("Longitude:", "\(state.lng)"))
            data.append(("Heading:", "\(state.heading)"))
        }
        return data
    }
    
    @State var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        let mainData = mainData
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            Text(tracker.label)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom)
            ForEach((0..<mainData.count)) { index in
                GridRow {
                    Text(mainData[index].0).fontWeight(.bold)
                    Text(mainData[index].1)
                }
            }
            if let state = tracker.state {
                Map(position: $mapPosition) {
                    Marker(
                        tracker.label,
                        coordinate: .init(
                            latitude: state.lat,
                            longitude: state.lng
                        )
                    )
                }
                .padding(.top)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .navigationTitle("Tracker Details")
        .presentationDetents([.fraction(0.6)])
        .onAppear {
            guard let state = tracker.state else { return }
            mapPosition = .region(
                MKCoordinateRegion(
                    center: .init(latitude: state.lat, longitude: state.lng),
                    span: .init(latitudeDelta: 1, longitudeDelta: 1)
                )
            )
        }
    }
}

extension View {
    
    func onContentSizeChange(_ onChange: @escaping (CGSize) -> Void) -> some View {
        // Used to size sheet detents to content height.
        // (SwiftUI doesn't provide a direct "intrinsic height" API for sheets.)
        self.overlay {
            GeometryReader { geometry in
                Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear { onChange(geometry.size) }
                    .onChange(of: geometry.size) { onChange(geometry.size) }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TrackerDetails(tracker: .demo())
    }
}
