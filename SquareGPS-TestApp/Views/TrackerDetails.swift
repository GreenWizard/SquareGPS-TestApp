import SwiftUI
import SwiftData

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
            data.append(("Lattitude:", "\(state.lat)"))
            data.append(("Longditute:", "\(state.lng)"))
            data.append(("Heading:", "\(state.heading)"))
        }
        return data
    }
    
    @State var contentHeight: CGFloat = 1
    
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
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white)
        .navigationTitle("Tracker Details")
        .onContentSizeChange { contentHeight = $0.height }
        .presentationDetents([.height(contentHeight)])
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
