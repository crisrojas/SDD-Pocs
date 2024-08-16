#  Async List Protocol

The goal of this playground is similar to what I tried to achive on [[23.11.17.Generic async list protocol]],

The idea is to have a minimal api for rendering collections from remote data apis.

Wanted api:

struct MyView: AsyncList {

    // Give it a url to render
    var url = "http://localhost:3000/users"
    
    // Give it a row
    func row(_ item: MJ) -> some View {
        Text(item.firstName)
    }
}

AsyncList automatically handles the collection state and renders row. This could be really useful for apps that have screens that only display information without shared states, like [Vitrines de Chartres](https://apps.apple.com/cl/app/vitrines-chartres/id1537994155)
