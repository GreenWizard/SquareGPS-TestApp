import SwiftUI
import SwiftData

struct TrackerDetails: View {
    
    var tracker: Tracker
    
    var tagBindings: String? {
        guard !tracker.tagBindings.isEmpty else { return nil }
        return tracker.tagBindings.reduce("") { result, binding in
            result.isEmpty ? "\(binding)" : "\(result); \(binding)"
        }
    }
    
    var mainData: [(String, String)] {
        var data = [
            ("ID:", "\(tracker.id)"),
            ("Model", "\(tracker.source.model)"),
            ("Group ID:", "\(tracker.groupId)"),
        ]
        if let tagBindings {
            data.append(("Tag Bindings:", "\(tagBindings)"))
        }
        if let phone = tracker.phone {
            data.append(("Phone:", "\(phone)"))
        }
        return data
    }
    
    @State var contentHeight: CGFloat = 0
    
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
