//
//  NamingConventions.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 22/11/23.
//

import SwiftUI

/// #private
///
/// @todo: ver otra vez el vídeo, parece que desde el principio hay una variable "name" de username
///
/// This is something  I saw recently in a video of Azam:
///
///  https://www.youtube.com/watch?v=9xG6tkfaPzQ
///
///
/// If you read this Azam, I'm not shiting in you.
/// I'm just developping a train of thought triggered by your video.
///
/// In fact I was enjoying it till I just stopped watching it so I can write this piece of test and gain some clarity.
///
/// For all the other readers, go watch the video. Is a good video.
///
/// Ok, lets say we have a coffe feature in our app, that lets create coffees and persist them somewhere.
///
///
struct AddCoffee: View {
    
    /// When writing future proof names for variables/methods,
    /// You may want to concile both, explicitness and conciseness.
    ///
    /// In this example we got a screen for creating coffes with a given name
    /// Then you have the variable binded to textfield input.
    ///
    /// You could call it like this:
    ///
    @State var coffeName = ""
    
    var body: some View {
        VStack {
            TextField("Enter name", text: $coffeName)
            Button("Create coffee") { create?(coffeName) }
        }
    }
    
    /// But I think we can do better.
    /// Note that "coffee" is a contextual keyword.
    ///
    /// It could be useful if we were in a different domain context.
    ///
    /// You got explicitness, but not concisness.
    /// Since you're in the same domain context: The domain is coffes, right?,
    ///
    /// slurp ☕️
    ///
    /// Here we are at the AddCoffee's screen, 
    /// so the context is easily inferred by the reader.
    ///
    /// Thus, the keyword becomes redundant and we can confidently ommit it:
    ///
    @State var name = ""
    var body_2: some View {
        VStack {
            TextField("Enter name", text: $name)
            Button("Create coffee") { create?(name) }
        }
    }
    
    /// But this is a simply screen, what if I need another "name" variable ?
    /// Like what if I need to attach the name of a user on the creation process?
    ///
    /// Well, then it make sense to namespace your variables.
    /// You can do however this however you feel of course:
    /// userName + coffe, userName + name alone, name + coffeName ...
    ///
    @State var coffe    = ""
    @State var userName = ""
    var body_3: some View {
        VStack {
            TextField("Enter coffe name", text: $coffe)
            TextField("Enter user name" , text: $userName)
            Button("Create coffee") { create(coffe, with: userName) }
        }
    }
    
    /// Strive for simplicity. Nothing beats it, but it comes with trial and error.
    ///
    /// Happy coding ✌️
    
   
    /// End Note: For reusability you may want to inject the "create" method.
    /// But it may not be necessary
    ///
    var create: ((String)->Void)?
    var _create: ((String, String)->Void)?
    
    /// Wrap inside a function if you think its worth it (you gain some clarity)
    /// Use at your discretion:
    ///
    func create(_ coffe: String, with userName: String) {
        _create?(coffe, userName)
    }
}
