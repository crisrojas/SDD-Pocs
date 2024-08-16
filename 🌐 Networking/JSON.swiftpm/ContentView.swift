import SwiftUI

struct ContentView: View {
    let array = Array(0...10).map { id in
        JSON { obj in
            obj.id = id.json()
            obj.30 = 30
        }
    }
    
    @State var object = JSON { obj in
        obj.age = 40
        obj.500 = "bg-500"
    }
    
    var binding: Binding<String> {
        .init(
            get: { object.name },
            set: { object.name = $0.json() }
        )
    }
    
    var body: some View {
        VStack {
            Text(object.500)
            TextField("Name", text: binding)
            
            ForEach(array, id: \.id) { item in
                int(item.id)
            }
        }
        .onAppear {
            print(object.debugDescription)
        }
    }
    
    func int(_ int: Int) -> some View {
        int.description
    }
    
    func double(_ double: Double) -> some View {
        double.description
    }
    
    func bool(_ bool: Bool) -> some View {
        bool.description
    }
    
    func fetched() -> some View {
        AsyncJSON(TmdbApi.popular) { result in
            ForEach(result.array, id: \.id) { item in
                Text(item.title)
            }
        }
    }
}

extension String: View {
    public var body: Text {Text(self)}
}
