//
//  FavoriteView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.05.24.
//

import SwiftUI

struct FavoriteView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var breweries: [Brewery] = []
    @State private var isLoading = false
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
                
                Text("Favorites")
                    .font(.title)
                Spacer()
                
                Button(action: {
                    showingIconDetails.toggle() 
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
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top, 20)
            } else if breweries.isEmpty {
                Text("No favorite breweries found.")
                    .font(.headline)
                    .padding(.top, 20)
            } else {
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
                    }
                }
            }
            Spacer()
        }.navigationBarHidden(true)
            .sheet(isPresented: $showingIconDetails) {
                IconDetailSheet()
            }
            .onAppear {
                fetchFavorites()
            }
    }
    
    func fetchFavorites() {
        guard let favoriteIDs = UserDefaults.standard.array(forKey: "FavoriteBreweries") as? [String] else {
            print("No favorites found in local storage")
            return
        }
        
        isLoading = true
        breweries = []
        
        breweryService.fetchAllBreweries { allBreweries, error in
            if let allBreweries = allBreweries {
                self.breweries = allBreweries.filter { favoriteIDs.contains($0.id) }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
            self.isLoading = false
        }
    }
}



#Preview {
    FavoriteView()
}
