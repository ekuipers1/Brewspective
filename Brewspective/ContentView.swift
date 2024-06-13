//
//  ContentView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate a network load or any asynchronous task
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            // Once the loading is complete, update the state
                            self.isLoading = false
                        }
                    }
            } else {
                NavigationView {
                    Group {
                        switch navigationManager.currentView {
                        case .home:
                            BrewHome()
                        case .breweryAll:
                            BreweryView()
                        case .breweryFav:
                            FavoriteView()
                        case .breweryType:
                            BreweryTypeView()
                        case .breweryMap:
                            BreweryMapView()
                        case .brewerySettings:
                            BrewerySettingsView()
                        case .brewerySettingsAdd:
                            AddEstablishmentView()
                        case .brewerySettingsUpdate:
                            UpdateEstablishmentView()
                        case .breweryCountry:
                            BreweryCountryView()
                        case .breweryCountryDetail:
                            if let selectedCountry = navigationManager.selectedCountry {
                                BreweryCountryViewDetail(country: selectedCountry)
                            } else {
                                Text("No Country Selected")
                            }
                        case .breweryDetail:
                            if let breweryId = navigationManager.selectedBreweryId {
                                BreweryDetailView(breweryId: breweryId)
                            } else {
                                Text("No Brewery Selected")
                            }
                        case .breweryTypeViewDetail:
                            if let selectedIcon = navigationManager.selectedIcon {
                                BreweryTypeViewDetail(icon: selectedIcon)
                            } else {
                                Text("No Icon Selected")
                            }
                        }
                    }
                    .navigationTitle("Navigation")
                }
                .environmentObject(navigationManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
