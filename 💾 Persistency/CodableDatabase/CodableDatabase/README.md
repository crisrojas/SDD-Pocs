# Codable Observable Database


 The goal of this playground is exploring the idea of a generic, observable database that can
 automatically work with any codable struct, for quick prototyping.
 
 The idea is to have an api like this:
 
 @StateObject var genericDatabase = Database()
 
 ...
 genericDatabase.upsert(shoppingList)
 let todos: [Todo] = genericDatabase.read()
 genericDatabase.delete(recipe.id)
 
 So we can just quick start a project and have a working persistence solution out of the box.
 It may a bit unnecessary, as we could just leverage CoreData for quick prototyping, nonetheless, still useful to have more options on the toolbox.
 
 Also, a different architecture that may be worth of exploring is a resource based one, instead of centralizing persitency in a single ObservableObject, we could have a generic object per codable entity (see Swiftgrounds on networking).
 
 Something like:
 
 final class Observable<Resource: Identifiable, Codable> {
  var path: String = { Resource.className }
  var prefix: String = "prod"
  
  var saving-path: String { prefix + "-" + "path" + ".json" }
  
  @Published var data: [Resource] = read() { 
    didSet { persist() }
  }
  
  func read() {}
  func upsert(_ r: Resource) {}
  func delete(_ id: Resource.ID) 
  func persist() {
    // Persist to saving-path
  }
}
 
 Still, it was a fun exercise.
