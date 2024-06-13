//
//  BreweryView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI

struct BreweryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var breweries: [Brewery] = []
    @State private var allBreweries: [Brewery] = []
    @State private var isLoading = false
    @State private var page = 1
    @State private var searchText = ""
    @State private var showingIconDetails = false
    
    private let breweryService = BreweryService()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    navigationManager.pop()
                }) {
                    Image(systemName: "arrow.left")
                        .leftArrow()
                }
                .padding(.trailing, 10)
                Spacer()
                
                Text("Breweries")
                    .font(.title)
                Spacer()
                
                Button(action: {
                    showingIconDetails.toggle()  // Toggle the detail sheet
                }) {
                    Image(systemName: "questionmark.circle.fill")
                        .leftArrow()
                }
                .padding(.trailing, 20)
            }.frame(width: UIScreen.main.bounds.width, height: 60)
            
            HStack {
                Spacer()
                TextField("Search breweries...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: 60)
            
            ScrollView {
                LazyVStack {
                    ForEach(breweries.filter { $0.name.contains(searchText) || searchText.isEmpty }, id: \.id) { brewery in
                        Button(action: {
                            
                            UserDefaults.standard.set(brewery.id, forKey: "SelectedBreweryId")
                            print(brewery.id)
                            navigationManager.push(.breweryDetail, breweryId: brewery.id)
                        }) {
                            HStack {
                                Image(systemName: IconUtility.icon(for: brewery.brewery_type))
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                                    .padding()
                                Text(brewery.name)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.Brew_Text)
                            }
                        }
                    }
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                    } else {
                        Color.clear.onAppear {
                            fetchBreweries(query: searchText)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if breweries.isEmpty {
                    fetchBreweries(query: searchText)
                }
            }
        }
        .sheet(isPresented: $showingIconDetails) {
            IconDetailSheet()
        }
    }
    
    func fetchBreweries(query: String = "") {
        isLoading = true
        breweryService.fetchBreweries(query: query, page: page) { response, error in
            if let response = response {
                self.allBreweries.append(contentsOf: response)
                self.breweries = self.allBreweries
                self.page += 1
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
            self.isLoading = false
        }
    }
    
    func fetchMoreBreweries() {
        fetchBreweries(query: searchText)
    }
}

struct Brewery: Codable, Identifiable {
    let id: String
    let name: String
    let brewery_type: String
}



#Preview {
    BreweryView()
}



struct IconInfo: Identifiable {
    let id = UUID()
    let type: String
    let symbolName: String
    let descriptionKey: LocalizedStringKey
}


let icons = [
    IconInfo(type: "Micro", symbolName: "house.fill", descriptionKey: "micro_description"),
    IconInfo(type: "Nano", symbolName: "leaf.fill", descriptionKey: "nano_description"),
    IconInfo(type: "Regional", symbolName: "map.fill", descriptionKey: "regional_description"),
    IconInfo(type: "Brewpub", symbolName: "person.2.fill", descriptionKey: "brewpub_description"),
    IconInfo(type: "Large", symbolName: "shippingbox.fill", descriptionKey: "large_description"),
    IconInfo(type: "Planning", symbolName: "hammer.fill", descriptionKey: "planning_description"),
    IconInfo(type: "Bar", symbolName: "music.note.house.fill", descriptionKey: "bar_description"),
    IconInfo(type: "Contract", symbolName: "signature", descriptionKey: "contract_description"),
    IconInfo(type: "Proprietor", symbolName: "building.2.fill", descriptionKey: "proprietor_description"),
    IconInfo(type: "Closed", symbolName: "xmark.square.fill", descriptionKey: "closed_description")
]

struct IconDetailSheet: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack(){
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .leftArrow()
                        
                    }
                    Spacer()
                    Text("Legend")
                        .font(.title)
                        .fontWeight(.bold)
                        .accentColor(.brewText)
                        .padding()
                    Spacer()
                    
                }
                List(icons, id: \.id) { icon in
                    HStack {
                        Image(systemName: icon.symbolName)
                            .foregroundColor(Color.Brew_Text)
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .padding()
                        VStack(alignment: .leading) {
                            Text(icon.type.capitalized).font(.headline)
                            Text(icon.descriptionKey).font(.subheadline)
                        }
                    }
                }
            }
        }
    }
}



struct RefreshableScrollView<Content: View>: View {
    let showsIndicators: Bool
    let refreshAction: (() -> Void)?
    let content: () -> Content
    
    init(showsIndicators: Bool = true, refreshAction: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.showsIndicators = showsIndicators
        self.refreshAction = refreshAction
        self.content = content
    }
    
    var body: some View {
        if let refreshAction = refreshAction {
            ScrollView(showsIndicators: showsIndicators) {
                VStack {
                    PullToRefreshView(refreshAction: refreshAction)
                    content()
                }
            }
        } else {
            ScrollView(showsIndicators: showsIndicators, content: content)
        }
    }
}

struct PullToRefreshView: View {
    let refreshAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .global)
            if frame.origin.y > 50 {
                DispatchQueue.main.async {
                    refreshAction()
                }
            }
            return Color.clear
        }
        .frame(height: 0)
    }
}



