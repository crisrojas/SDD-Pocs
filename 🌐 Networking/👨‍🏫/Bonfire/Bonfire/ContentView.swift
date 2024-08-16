//
//  ContentView.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 02/12/2023.
//

import SwiftUI

let api = API()

struct ContentView: View {
    @ObservedObject var employees = api.employees
    @State var isLoading = true
    @State var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView().onAppear(perform: load)
                } else {
                   loadedView()
                }
            }
            .animation(.default, value: isLoading)
            .toolbar {
                SymbolButton("arrow.counterclockwise", action: load)
            }
        }
    }
    
    @ViewBuilder
    func loadedView() -> some View {
        if let errorMessage {
            errorMessage
        } else {
            successView()
        }
    }
    
    @ViewBuilder
    func successView() -> some View {
        if employees.list.isEmpty {
            "No data found"
        } else {
            List(employees.list.tuples(), id: \.id) { item in
                let name   = item.value[EK.name  ].stringValue
                let age    = item.value[EK.age   ].intValue
                let salary = item.value[EK.salary].intValue
                NavigationLink(name) {
                    EmployeeDetail(name: name, age: age, salary: salary)
                }
            }
        }
    }
    
    func load() {
        isLoading = true
        employees.load().onCompletion {
            isLoading = false
        }
    }
}


/// If you use MJ, you still have an intermedaite model to render the list item detail.
struct EmployeeDetail: View {
    let name: String
    let age: Int
    let salary: Int
    
    var body: some View {
        VStack {
            HStack {
                "Age: ".body + age.body
            }
            HStack {
                "Name: " + name
            }
            HStack {
                "Salary ".body + salary.body
            }
        }
    }
}


extension Int: View {
    public var body: Text {
        Text(description)
    }
}

struct SymbolButton: View {
    let systemName: String
    let action: () -> Void
    init(_ systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: symbol)
    }
    
    func symbol() -> some View {
        Image(systemName: systemName)
    }
}

extension String: View {
    public var body: Text {
        Text(self)
    }
}

extension [Employee]: View {
    public var body: some View {
        List(self) { item in
            NavigationLink {
                item
            } label: {
                item.name
            }
        }
    }
}

extension Employee: View {
    public var body: some View {
        VStack {
            HStack {
                "Name: " + name
            }
            HStack {
                "Age: ".body + age.body
            }
            HStack {
                "Salary: ".body + salary.body
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func insideNavView() -> some View {
        NavigationStack {self}
    }
    func navigationfy() -> some View {
        NavigationView {self}
    }
}
