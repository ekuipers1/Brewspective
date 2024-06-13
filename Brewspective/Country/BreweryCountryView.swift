//
//  BreweryCountryView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 08.05.24.
//

import SwiftUI

struct Country: Identifiable {
    var id: String
    var nameKey: LocalizedStringKey
    var flag: String
}

struct BreweryCountryView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    let countries = [
        Country(id: "austria", nameKey: "Austria", flag: "🇦🇹"),
        Country(id: "england", nameKey: "England", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿"),
        Country(id: "france", nameKey: "France", flag: "🇫🇷"),
        Country(id: "isle_of_man", nameKey: "Isle of Man", flag: "🇮🇲"),
        Country(id: "ireland", nameKey: "Ireland", flag: "🇮🇪"),
        Country(id: "poland", nameKey: "Poland", flag: "🇵🇱"),
        Country(id: "portugal", nameKey: "Portugal", flag: "🇵🇹"),
        Country(id: "scotland", nameKey: "Scotland", flag: "🏴󠁧󠁢󠁳󠁣󠁴󠁿"),
        Country(id: "singapore", nameKey: "Singapore", flag: "🇸🇬"),
        Country(id: "south_korea", nameKey: "South Korea", flag: "🇰🇷"),
        Country(id: "united_states", nameKey: "United States", flag: "🇺🇸")
    ]
    
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
                Text("Countries")
                    .font(.title)
                    .padding(.trailing, 40)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: 60)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(countries) { country in
                        Button(action: {
                            navigationManager.selectedCountry = country
                            navigationManager.push(.breweryCountryDetail)
                        }) {
                            VStack {
                                Text(country.flag)
                                    .font(.largeTitle)
                                Text(country.nameKey)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}


struct BreweryCountryView_Previews: PreviewProvider {
    static var previews: some View {
        BreweryCountryView()
    }
}



