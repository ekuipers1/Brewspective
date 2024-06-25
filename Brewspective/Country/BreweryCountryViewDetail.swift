//
//  BreweryCountryViewDetail.swift
//  Brewspective
//
//  Created by Erik Kuipers on 08.05.24.
//

import SwiftUI

struct BreweryCountryViewDetail: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    let country: Country
    @State private var breweries: [BreweryDetail] = []
    @State private var isLoading = false
    @State private var page = 1
    @State private var canLoadMore = true
    @State private var error: Error?
    @State private var showErrorAlert = false
    @State private var searchText = ""
    
    private let breweryService = BreweryServiceCountry()
    @Environment(\.presentationMode) var presentationMode
    
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
                Text("\(country.flag)")
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
                                loadMoreBreweries()
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
                loadMoreBreweries()
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(error?.localizedDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func loadMoreBreweries(query: String = "") {
        guard !isLoading else { return }
        isLoading = true
        breweryService.fetchBreweriesCountry(byCountry: country.id, page: page) { response, error in
            self.isLoading = false
            if let response = response {
                if response.count < 50 {
                    self.canLoadMore = false
                }
                self.breweries.append(contentsOf: response)
                self.page += 1
            } else if let error = error {
                self.error = error
                self.showErrorAlert = true
                self.canLoadMore = false
            }
        }
    }
}

struct BreweryCountryViewDetail_Previews: PreviewProvider {
    static var previews: some View {
        BreweryCountryViewDetail(country: Country(id: "austria", nameKey: "austria", flag: "🇺🇸"))
            .environmentObject(NavigationManager())
    }
}

