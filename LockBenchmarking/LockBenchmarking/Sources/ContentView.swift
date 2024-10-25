import SwiftUI

public struct ContentView: View {
    @State var results: [String] = []
    public init() {}

    public var body: some View {
        VStack {
            if results.isEmpty {
                ProgressView()
            } else {
                ForEach(results, id: \.self) { result in
                    Text(result)
                }
            }
        }
        .task {
            let results = await Benchmarking().benchmark()
            print(results.joined(separator: "\n"))
            self.results = results
        }
    }
}
