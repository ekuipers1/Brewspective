//
//  BreweryMapDetailsView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 02.05.24.
//

import SwiftUI
import MessageUI


struct BreweryMapDetailsView: View {
    var brewery: BreweryMap
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isSheetPresented = false
    @State private var isAlertPresented = false
    @State private var isHeartFilled = false
    
    var body: some View {
        
        VStack(){
            HStack {
                Text(brewery.name)
                    .font(.title)
                    .padding(.leading, 20)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .padding(.trailing, 20)
                
                Spacer()
                
                Button(action: {
                    toggleFavorite()
                }) {
                    Image(systemName: isHeartFilled ? "heart.fill" : "heart")
                        .heart()
                        .foregroundColor(isHeartFilled ? .red : .gray)
                }
                .padding(.trailing, 15)
            }.frame(width: UIScreen.main.bounds.width, height: 60)
                .padding(.top, 20)
            Spacer()
            VStack(){
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color.Brew_Text)
                        .font(.title2)
                    Text("\(brewery.street ?? "N/A")")
                        .font(.title2)
                    Spacer()
                }
                .padding(.leading, 20)
                
                HStack {
                    Image(systemName: "location.circle")
                        .foregroundColor(Color.Brew_Text)
                        .font(.title2)
                    Text("\(brewery.city ) , \(brewery.state )")
                        .font(.title2)
                    Spacer()
                }
                .padding(.leading, 20)
                
                if let phone = brewery.phone {
                    HStack {
                        Image(systemName: "phone.circle")
                            .foregroundColor(Color.Brew_Text)
                            .font(.title2)
                        Link(phone, destination: URL(string: "tel:\(phone)")!)
                            .foregroundColor(Color.Brew_Text)
                            .font(.title2)
                        Spacer()
                    }
                    .padding(.leading, 20)
                }
                
                if let website = brewery.websiteURL {
                    HStack {
                        Image(systemName: "link.circle")
                            .foregroundColor(Color.Brew_Text)
                            .font(.title2)
                        Link("Website", destination: URL(string: website)!)
                            .foregroundColor(Color.Brew_Text)
                            .font(.title2)
                            .underline()
                        Spacer()
                    }
                    .padding(.leading, 20)
                    
                }
            }.padding(.bottom, 20)
            
            Image("BreweryHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.bottom)
            
        }
        .onAppear {
            loadFavoriteStatus()
        }
    }
    
    func loadFavoriteStatus() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteBreweries") as? [String] {
            isHeartFilled = savedFavorites.contains(brewery.id)
        }
    }
    
    func toggleFavorite() {
        var savedFavorites = UserDefaults.standard.array(forKey: "FavoriteBreweries") as? [String] ?? []
        if let index = savedFavorites.firstIndex(of: brewery.id) {
            savedFavorites.remove(at: index)
            isHeartFilled = false
            print("Removed from favorites: \(brewery.id)")
        } else {
            savedFavorites.append(brewery.id)
            isHeartFilled = true
            print("Added to favorites: \(brewery.id)")
        }
        UserDefaults.standard.set(savedFavorites, forKey: "FavoriteBreweries")
    }
    
    
}

struct BreweryMapDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BreweryMapDetailsView(brewery: BreweryMap(id: "4431b884-6f1c-495c-8b78-ab3ad0cc9ba1", name: "Example Brewery", breweryType: "Large", address1: "123 Main St", city: "City", stateProvince: "State", postalCode: "12345", country: "Country", longitude: "0.0", latitude: "0.0", phone: nil, websiteURL: nil, state: "State", street: "123 Main St"))
    }
}


extension Binding where Value == Result<MFMailComposeResult, Error>? {
    var isPresented: Bool {
        return self.wrappedValue != nil
    }
}


struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .opacity(configuration.isPressed ? 0.8 : 1.0) // Adjust opacity when pressed
    }
}
