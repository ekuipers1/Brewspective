//
//  BreweryDetailView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI
import MapKit

struct BreweryDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    let breweryId: String
    @State private var brewery: BreweryDetail?
    @State private var coordinate: IdentifiableCoordinate?
    @State private var showingDataOptions: Bool = false
    @State private var isHeartFilled = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        UserDefaults.standard.set("", forKey: "SelectedBreweryId")
                        navigationManager.pop()
                    }) {
                        Image(systemName: "arrow.left")
                            .leftArrow()
                    }
                    Spacer()
                    Text("Brewery Information")
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Button(action: {
                        showingDataOptions.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .leftArrow()
                    }
                    .sheet(isPresented: $showingDataOptions) {
                        DetailViewHelp(breweryId: breweryId)
                    }
                    .padding(.trailing, 20)
                }
                .frame(width: UIScreen.main.bounds.width, height: 60)
                
                VStack {
                    if let brewery = brewery {
                        Spacer()
                        HStack {
                            Text(brewery.name)
                                .font(.largeTitle)
                                .padding(.leading, 20)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .padding(.trailing, 20)
                                .textSelection(.enabled)
                            Spacer()
                            
                            Button(action: {
                                toggleFavorite()
                            }) {
                                Image(systemName: isHeartFilled ? "heart.fill" : "heart")
                                    .heart()
                                    .foregroundColor(isHeartFilled ? .red : .gray)
                            }
                            .padding(.trailing, 15)
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 40)
                        Spacer()
                        
                        AddressView(street: brewery.street, city: brewery.city, state: brewery.state_province)
                        
                        if let phone = brewery.phone {
                            HStack {
                                Image(systemName: "phone.circle")
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                Link(phone, destination: URL(string: "tel:\(phone)")!)
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.leading, 20)
                        }
                        
                        if let website = brewery.website_url {
                            HStack {
                                Image(systemName: "link.circle")
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                Link("Website", destination: URL(string: website)!)
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title2)
                                    .underline()
                                Spacer()
                            }
                            .padding(.leading, 20)
                        }
                        Spacer()
                        Spacer()
                    } else {
                        Text("Loading...")
                    }
                }
                .navigationBarHidden(true)
                
                if let coordinate = coordinate {
                    BreweryMapViewDetail(coordinate: coordinate)
                        .frame(height: geometry.size.height / 2)                  
                        .padding(.bottom, 20)
                } else {
                    Text("Loading Map...")
                        .frame(height: 200)
                }
            }
            .onAppear {
                fetchBreweryDetail()
                loadFavoriteStatus()
            }
        }
    }
    
    
    func loadFavoriteStatus() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteBreweries") as? [String] {
            isHeartFilled = savedFavorites.contains(breweryId)
        }
    }
    
    func toggleFavorite() {
        var savedFavorites = UserDefaults.standard.array(forKey: "FavoriteBreweries") as? [String] ?? []
        if let index = savedFavorites.firstIndex(of: breweryId) {
            savedFavorites.remove(at: index)
            isHeartFilled = false
            print("Removed from favorites: \(breweryId)")
        } else {
            savedFavorites.append(breweryId)
            isHeartFilled = true
            print("Added to favorites: \(breweryId)")
        }
        UserDefaults.standard.set(savedFavorites, forKey: "FavoriteBreweries")
        
    }
    
    func fetchBreweryDetail() {
        guard let url = URL(string: "https://api.openbrewerydb.org/breweries/\(breweryId)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(BreweryDetail.self, from: data) {
                    DispatchQueue.main.async {
                        self.brewery = decodedResponse
                        self.updateMapView(for: decodedResponse)
                    }
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    
    func updateMapView(for brewery: BreweryDetail) {
        if let latitude = brewery.latitude, let longitude = brewery.longitude, let lat = Double(latitude), let lon = Double(longitude) {
            self.coordinate = IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            let address = "\(String(describing: brewery.street)), \(String(describing: brewery.city)), \(String(describing: brewery.state_province))"
            reverseGeocode(address: address)
        }
    }
    
    func reverseGeocode(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.coordinate = IdentifiableCoordinate(coordinate: location.coordinate)
                }
            } else {
                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}


#Preview {
    BreweryDetailView(breweryId: "b54b16e1-ac3b-4bff-a11f-f7ae9ddc27e0")
}


struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}


struct BreweryMapViewDetail: View {
    var coordinate: IdentifiableCoordinate
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: coordinate.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)),
            annotationItems: [coordinate]) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Image("MapPointer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
        }
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .edgesIgnoringSafeArea(.horizontal)
            .padding(.bottom, 20)
    }
}

struct DetailViewHelp: View {
    let breweryId: String
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            
            HStack {
                Text("How to navigate")
                    .font(.title)
                    .padding()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.brewTextInf)
                        .font(.title)
                        .padding()
                        .background(Color.brewText)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 20)
                }
                
            }.frame(width:widthFull, height: 60)
                .padding(.top, 40)
            
            
            Text("When you tap on the address the information will be copied to the clipboard and you can use it, for example, to find your way to the establishment. When you tap on the phone number, it will give you the option to call, and the website link will open the page in your browser."
            )
            .padding()
            
            DisclosureGroup(isExpanded: $isExpanded) {
                ScrollView {
                    VStack {
                        ForEach(icons) { icon in
                            HStack(alignment: .top) {
                                Image(systemName: icon.symbolName)
                                    .foregroundColor(Color("Brew_Text"))
                                    .font(.title)
                                    .frame(width: 20, height: 20)
                                    .padding(.leading, 10)
                                VStack(alignment: .leading) {
                                    Text(icon.type.capitalized)
                                        .font(.headline)
                                    Text(icon.descriptionKey)
                                        .font(.subheadline)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }.padding(.leading, 10)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .frame(width: widthFull - 80)
                }
                .frame(maxHeight: 200)
                
                
            } label: {
                HStack {
                    Text("Legend")
                        .font(.headline)
                        .accentColor(.brewText)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .accentColor(.brewText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .accentColor(.clear)
            
            Spacer()
            
            Text("If you own the currently selected establishment and notice any inaccuracies, please let us know by clicking the Update Establishment button.")
                .padding()
            
            HStack(){
                Button("Update Establishment") {
                    navigationManager.push(.brewerySettingsUpdate)
                }
                .padding()
                .font(.title3)
                .foregroundColor(.brewTextInf)
                .background(Color.brewText)
                .cornerRadius(10)
                
            }
        }
        .padding()
    }
}


struct AddressView: View {
    let street: String?
    let city: String?
    let state: String?
    @State private var combinedText: String = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "location.circle")
                    .foregroundColor(Color.Brew_Text)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text("\(street ?? "N/A")").font(.title2)
                    Text("\(city ?? "N/A"), \(state ?? "N/A")")
                        .font(.title2)
                        .onTapGesture {
                            combinedText = "\(street ?? "N/A"), \(city ?? "N/A"), \(state ?? "N/A")"
                            UIPasteboard.general.string = combinedText // Optionally copy to clipboard
                            print("Combined text: \(combinedText)")
                            showAlert = true // Show alert
                        }
                }
                Spacer()
            }
            .padding(.leading, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Address Copied"), message: Text("The address has been copied to the clipboard."), dismissButton: .default(Text("OK")))
            }
        }
    }
}


