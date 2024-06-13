//
//  BreweryTypeView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI

struct BreweryTypeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
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
                Text("Brewery Type")
                    .font(.title)
                    .padding(.trailing, 40)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width, height: 60)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(icons) { icon in
                        Button(action: {
                            navigationManager.push(.breweryTypeViewDetail, icon: icon)
                        }) {
                            VStack {
                                Image(systemName: icon.symbolName)
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                                    .padding()
                                VStack(alignment: .leading) {
                                    Text(icon.type.capitalized).font(.headline)
                                        .foregroundColor(Color.Brew_Text)
                                }
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
        }
    }
}



#Preview {
    BreweryTypeView()
}


struct IconView: View {
    let icon: IconInfo
    @State private var isSheetPresented = false
    @State private var breweries: [BreweryDetail]?
    @State private var error: Error?
    
    var body: some View {
        Button(action: {
            self.fetchBreweries()
            self.isSheetPresented = true
        }) {
            Image(systemName: icon.symbolName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isSheetPresented) {
            if let breweries = breweries {
                
                Text("Fetched breweries: \(breweries.count)")
                ScrollView {
                    LazyVStack {
                        ForEach(breweries, id: \.id) { brewery in
                            Button(action: {
                            }) {
                                HStack {
                                    
                                    Image(systemName: IconUtility.icon(for:brewery.brewery_type))
                                        .foregroundColor(Color.Brew_Text)
                                        .font(.title)
                                    VStack(alignment: .leading) {
                                        Text(brewery.name)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(Color.Brew_Text)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.Brew_Text_Inf)
                            .cornerRadius(5)
                            .shadow(radius: 1)
                        }
                    }
                }
                
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                ProgressView()
            }
        }
    }
    
    private func fetchBreweries() {
        let service = BreweryServiceType()
        let iconType = icon.type.lowercased()
        service.fetchBreweriesType(byType: iconType) { breweries, error in
            if let error = error {
                self.error = error
            } else {
                self.breweries = breweries
            }
        }
    }
}
