//
//  BrewHome.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI

struct BrewHome: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    
    var body: some View {
        VStack {
            Button(action: { navigationManager.push(.breweryAll) }) {
                HStack {
                    Image(systemName: "shippingbox")
                    Text("Breweries")
                        .padding(.leading, 25)
                    
                    Spacer()
                }
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            Button(action: { navigationManager.push(.breweryFav) }) {
                HStack {
                    Image(systemName: "heart")
                    Text("Breweries Favorites")
                        .padding(.leading, 25)
                    
                    Spacer()
                }
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button(action: { navigationManager.push(.breweryMap) }) {
                HStack {
                    Image(systemName: "map")
                    Text("Brewery Map")
                        .padding(.leading, 25)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
                .font(.title2)
            }
            .padding(.horizontal)
            
            Button(action: { navigationManager.push(.breweryType) }) {
                HStack {
                    Image(systemName: "house")
                    Text("Brewery Types")
                        .padding(.leading, 25)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
                .font(.title2)
            }
            .padding(.horizontal)
            
            Button(action: { navigationManager.push(.breweryCountry) }) {
                HStack {
                    Image(systemName: "globe.desk")
                    Text("Brewery by Country")
                        .padding(.leading, 25)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
                .font(.title2)
            }
            .padding(.horizontal)
            
            Button(action: { navigationManager.push(.brewerySettings) }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                        .padding(.leading, 25)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.Brew_Text)
                .foregroundColor(.Brew_Text_Inf)
                .cornerRadius(8)
                .font(.title2)
            }
            .padding(.horizontal)
            .padding(.top, 50)
            
            
            Spacer()
            Image("Bottom_1")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            
        }
        .padding(.top, 50)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        
    }
}



#Preview {
    BrewHome()
}
