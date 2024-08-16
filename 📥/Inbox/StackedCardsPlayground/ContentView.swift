import SwiftUI
import SwiftWind

extension WindColor: Equatable {
  
  
  public static func == (lhs: WindColor, rhs: WindColor) -> Bool {
    lhs.c50 == rhs.c50
  }
}

struct DetailModel: Equatable {
  
  let emoji: String
  let color: WindColor
}


final class Manager: ObservableObject {
  @Published var selectedIndex: Int?
  @Published var detailModel: DetailModel?
  
  @Published var namespace: Namespace.ID?
  
  func toggle(index: Int) {
    guard
    let selectedIndex = selectedIndex,
    selectedIndex == index
    else {
      selectedIndex = index
      return
    }
    
    self.selectedIndex = nil
  }
}

struct ContentView: View {
  
  @StateObject var manager = Manager()
  
  
 var model: [DetailModel] = [
    DetailModel(emoji: "👍", color: WindColor.blue),
    DetailModel(emoji: "🐛", color: WindColor.lime),
    DetailModel(emoji: "🍻", color: WindColor.amber),
    DetailModel(emoji: "⌛️", color: WindColor.rose),
  ]
  
  
  
    var body: some View {
      
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          
          ForEach(model.indices) { index in
            Row(
              index: index,
              model: model[index]
            )
            .environmentObject(manager)
          }
          
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(alignment: .leading)
        .padding(.top, 24)
        
      }
      .animation(.spring(), value: manager.detailModel)
      .overlay(detailView)
    }
  
  @State var appear: Bool = false
 
  @ViewBuilder
  var detailView: some View {
    if let detailModel = manager.detailModel, let namespace =  manager.namespace {
        VStack {
          ScrollView(showsIndicators: false) {
            HStack {
              VStack(alignment: .leading, spacing: 12) {
              
                ForEach(Array(0...24).indices) { index in
                  Text("Behaviour \(index)")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(detailModel.color.c600)
                }
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    appear = true
                  }
                }
                .onDisappear {
                  appear = false
                }
              }
              Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
            .padding(.bottom, 24)
          }
          
          .frame(maxWidth: .infinity)
          .frame(maxHeight: .infinity)
          .overlay(
            HStack {
            Text(detailModel.emoji)
                .matchedGeometryEffect(id: "emoji", in: namespace)
              
              Spacer()
              Image(systemName: "arrow.up.left.and.arrow.down.right")
                .foregroundColor(detailModel.color.c600)
                .matchedGeometryEffect(id: "expand.collapse", in: namespace)
                .onTapGesture {
                  appear = false
                  withAnimation(.spring()) {
                    manager.detailModel = nil
                  }
                }
              
            }
            .padding()
//            .background(
//              detailModel.color.c200.cornerRadius(16).opacity(appear ? 0.8 : 0)
//            )
            ,
            
            alignment: .top
          
          )
          .background(
            detailModel.color.c200
              .cornerRadius(16)
              .shadow(
                color: .black.opacity(0.1),
                radius: 10,
                x: 0,
                y: 0
              )
              .matchedGeometryEffect(id: "color", in: namespace)
          )
          
          .padding(12)
        }
        .animation(.easeInOut, value: appear)
        .background(Color.black.opacity(0.3))
        .background(
          .ultraThinMaterial
        )
        
      } else {
        EmptyView()
      }
  }
}


struct Row: View {
  
  @EnvironmentObject var manager: Manager
 
  @Namespace var namespace
  let index: Int
  let model: DetailModel
  
  private var offset: CGFloat {
//    guard let selectedIndex = manager.selectedIndex else {
      if index == 0 {
        return 0
      } else {
        return Double(index) * -140
      }
//    }
    
//    if selectedIndex != index {
//      return 0
//    } else {
//      return Double(index) * -140
//    }
  }
  
  private var isSelected: Bool {
    manager.selectedIndex == index
  }
  
  private var offsetToAdd: CGFloat {
    
    guard let selectedIndex = manager.selectedIndex else {
      return 0
    }
    
    if selectedIndex == index {
      return 0
    } else {
      
      if selectedIndex < index {
        return 110
      } else {
        return 0
      }
    }
    
  }
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        HStack {
          Text(model.emoji)
            .matchedGeometryEffect(id: "emoji", in: namespace)
          Spacer()
          if isSelected {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
              .matchedGeometryEffect(id: "expand.collapse", in: namespace)
              .foregroundColor(model.color.c500)
              .onTapGesture {
                
                withAnimation(.spring()) {
                  manager.detailModel = model
                }
              }
          }
        }
        
          list
          .opacity(isSelected ? 1 : 0)
          .padding(.top, 16)
          .padding(.bottom, 32)
        
        Spacer()
      }
      
      Spacer()
      
    
    }
    .padding()
    .frame(maxWidth: .infinity)
    .frame(alignment: .leading)
    .background(model.color.c200.cornerRadius(16).matchedGeometryEffect(id: "color", in: namespace))
   
    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -10)
    .offset(y: offset + offsetToAdd)
    .animation(.spring(), value: offsetToAdd)
    .animation(.spring(), value: isSelected)
    .onTapGesture {
      manager.namespace = namespace
      manager.toggle(index: index)
    }
  }
  
  @ViewBuilder
  var list: some View {
    VStack(spacing: 12) {
      HStack {
  //      Text(emoji)
        Text("Behaviour 1")
          .font(.system(.body, design: .rounded))
          .fontWeight(.medium)
      }
      
      HStack {
  //      Text(emoji)
        Text("Behaviour 2")
          .font(.system(.body, design: .rounded))
          .fontWeight(.medium)
      }
      
      HStack {
  //      Text(emoji)
        Text("Behaviour 3")
          .font(.system(.body, design: .rounded))
          .fontWeight(.medium)
      }
    }
    
    .foregroundColor(model.color.c600)
  }
}
