import SwiftUI

struct BodyView: View {
    @Binding var showBrows: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                // Gridviews for thumbnails
                ModelsByCategoryGrid(showBrowse: $showBrows )
            }
            .navigationBarTitle(Text("Browse"), displayMode: .large)
            .navigationBarItems(trailing:
                    Button(action: {
                self.showBrows.toggle()
            }) {
                Text("Done").bold()
            })
        }
    }
}



struct ModelsByCategoryGrids: View {
    @Binding var showBrows : Bool

    let models = Models()
    
    var body: some View {
        VStack {
            ForEach(ModelCategory.allCases, id :  \.self) { category in
                
                // Only display grid if category contains items
                if let modelsByCategory = models.get(category: category) {
                    HorizontalGrid(showBrowse: $showBrows , title: category.label, items: modelsByCategory)
                }
            }
        }
    }
}

struct HorizontalGrids: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrows : Bool
    
    var title: String
    var items: [Model]
    private let gridItemLayout = [GridItem(.fixed(150))]
    
    var body: some View {
        VStack(alignment: .leading) {
            Seperator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach(0..<items.count) { index in
                        
                        let model = items[index]
                        
                        ItemButton(model: model) {
                            // Call the async method to  load modelEntity
                            model.asyncLoadModelEntity()
                            // Select model for placement
                            self.placementSettings.selectedModel = model
                            print("BrowseView: selected \(model.name) for placement")
                            self.showBrows = false
                        }
                    }
                }
                .padding(.horizontal,22)
                .padding(.vertical, 10)
            }
        }
    }
}

struct ItemButtons: View {
    let model: Model
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(uiImage: self.model.thumbnail)
                .resizable()
                .frame(height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(8.0)
        }
    }
}

struct Seperators: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}




