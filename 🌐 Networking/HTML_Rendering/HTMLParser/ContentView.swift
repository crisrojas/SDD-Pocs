//
//  ContentView.swift
//  HTMLParser
//
//  Created by Cristian Felipe Patiño Rojas on 28/03/2024.
//

import SwiftUI
import SwiftSoup

/*
 
The goal of this playground is to experiment with a way of consuming html as we usually would consume JSON.
So idea is to be able to turn websites or webapps (hypermedia-apis) into high quality apps without minimal changes
on the server side.
 
So we can turn this:

 <html>
 <body>
   <div>
   <div id="div1" name="recipes">
     <div item>
        <div name="id" style="display:none">1</id>
        <div name="title">Hamburger</div>
        <div name="description">Fresh hamburger with chicken, salad, tomatoes</div>
    </div>
     <div item>
        <div name="id" style="display:none">1</id>
        <div name="title">Sushi rolls</div>
        <div name="description">Delicious salmon avocado sushi rolls</div>
    </div>
   </div>
   </div>
   <div id="div2">This will be ignored</div>
   <div id="div3" name="content">This will be parsed</div>
 </body>
 </html>
 
 Into a consommable data structure (being a json string or a swift dict [String: Any]) :
 
 [
    "recipes": [
        { "id": 1, "title": "Hamburger", "description": "Fresh hamburger with chicken, salad, tomatoes" },
        { "id": 2, "title": "Sushi", "description": "Delicious salmon avocado sushi rolls" }
    ],
    "content": "This will be parserd"
 ]
 
 Then you could deserialize to a decodable structure or a MagicJson one:
 
 struct ContentView: View {
     @State var data = MJ()
     var body: some View {
         VStack {
             ForEach(data.recipes.arrayValue, id: \.title) { item in
                 Text(item.title)
             }
         }
         .padding()
         .onAppear(perform: parseb)
    }
 }

 */
struct ContentView: View {
    @State var data = MJ()
    var body: some View {
        VStack {
            ForEach(data.recipes.arrayValue, id: \.title) { item in
                Text(item.title)
            }
        }
        .padding()
        .onAppear(perform: parseb)
    }
    
    
    func parseb() {
      
        
        let htmlString = """
        <html>
        <body>
          <div>
          <div id="div1" name="recipes">
            <div name="title">Hamburger</div>
            <div name="title">Sushi</div>
          </div>
          </div>
          <div id="div2">Content 2</div>
          <div id="div3" object name="content">Content 3</div>
        </body>
        </html>
        """
        
        let doc = try! SwiftSoup.parse(htmlString)
        let dict = try? doc.parse()
        data = MJ(dict)
        print(data)
    }
}


func parserPreserving(html: String, attribute: String) -> Document? {
    do {
        // Parsea el HTML dado
        let doc: Document = try SwiftSoup.parse(html)
        
        // Selecciona todos los elementos que no contengan el atributo especificado
        let elementsToRemove = try doc.select(":not([\(attribute)])")
        
        // Elimina los elementos seleccionados
        try elementsToRemove.remove()
        
        // Devuelve el documento modificado
        return doc
    } catch {
        print("Error al procesar el HTML: \(error.localizedDescription)")
        return nil
    }
}


extension Document {
    func parse() throws -> [String: Any] {
        let elements = try! self.select("*[name]")
        var dict = [String: Any]()
        
        for element in elements.array().reversed() {
            let name = try element.attr("name")
            let value = try element.text()

            if !element.children().isEmpty() {
                var childDicts = [[String: Any]]()
                for child in element.children().filter({ $0.hasAttr("name") }) {
                    let childName  = try child.attr("name")
                    let childValue = try child.text()
                    let childDict  = [childName: childValue]
                    childDicts.append(childDict)
                }
                dict[name] = childDicts
            } else {
                if element.parent() == nil || element.parent() == body() {
                    dict[name] = value
                }
            }
        }
        
        return dict
    }
}

