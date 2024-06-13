//
//  BreweryTypeViewDetail.swift
//  Brewspective
//
//  Created by Erik Kuipers on 07.05.24.
//

import SwiftUI

struct BreweryTypeViewDetail: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var breweries: [BreweryDetail] = []
    @State private var isLoading = false
    @State private var page = 1
    @State private var searchText = ""
    @State private var canLoadMore = true
    @State private var error: Error?
    
    private let breweryService = BreweryServiceType()
    @Environment(\.presentationMode) var presentationMode
    let icon: IconInfo
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    navigationManager.pop()
                }) {
                    Image(systemName: "arrow.left")
                        .leftArrow()
                }
                
                Spacer()
                
                Text("Details for \(icon.type)")
                    .font(.title)
                    .padding(.trailing, 40)
                Spacer()
            }.frame(width: UIScreen.main.bounds.width, height: 60)
            
            TextField("Search breweries...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            ScrollView {
                LazyVStack {
                    ForEach(breweries.filter { $0.name.contains(searchText) || searchText.isEmpty }, id: \.id) { brewery in
                        Button(action: {
                            UserDefaults.standard.set(brewery.id, forKey: "SelectedBreweryId")
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
                    
                    if canLoadMore {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                        } else {
                            Button("Load More") {
                                fetchBreweries()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                page = 1
                breweries = []
                fetchBreweries()
            }
        }
    }
    
    func fetchBreweries(query: String = "") {
        guard canLoadMore else { return }
        isLoading = true
        breweryService.fetchBreweriesType(byType: icon.type.lowercased(), page: page) { response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let response = response {
                    if response.isEmpty {
                        self.canLoadMore = false
                    } else {
                        self.breweries.append(contentsOf: response)
                        self.page += 1
                    }
                } else if let error = error {
                    self.error = error
                    self.canLoadMore = false
                }
            }
        }
    }
}

struct BreweryTypeViewDetail_Previews: PreviewProvider {
    static var previews: some View {
        BreweryTypeViewDetail(icon: IconInfo(type: "Micro", symbolName: "house.fill", descriptionKey: "Description of Micro"))
            .environmentObject(NavigationManager())
    }
}

