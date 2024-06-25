//
//  BreweryMapDetailsView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 02.05.24.
//

import SwiftUI
import MessageUI
import CoreLocation
import MapKit

struct BreweryMapDetailsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    var brewery: BreweryMap
    @State private var result: Result<MFMailComposeResult, Error>?
    @State private var isSheetPresented = false
    @State private var isAlertPresented = false
    @State private var isHeartFilled = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var coordinateRoute: CLLocationCoordinate2D?
    
    @State private var imageCount = 0
    @State private var isGalleryPresented = false
    @State private var isCameraPresented = false
    @State private var image: UIImage? = nil
    
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
            
            
            AddressView(street: brewery.street, city: brewery.city, state: brewery.stateProvince)

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
            
            HStack {
                if let website = brewery.websiteURL {
                    Image(systemName: "link.circle")
                        .foregroundColor(Color.Brew_Text)
                        .font(.title)
                    Link("Website", destination: URL(string: website)!)
                        .foregroundColor(Color.Brew_Text)
                        .font(.title2)
                        .underline()
                }
                
                Spacer()
                Image(systemName: IconUtility.icon(for: brewery.breweryType))
                    .font(.title)
                    .padding(.trailing, 20)
            }
            .padding(.leading, 20)

        }.padding(.bottom, 20)
        
        Image("BreweryHome")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.bottom)
        
        HStack {
            Button(action: {
                if let latitude = CLLocationDegrees(brewery.latitude),
                   let longitude = CLLocationDegrees(brewery.longitude) {
                    openMapsAppWithDirections(to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), destinationName: "Destination")
                } else {
                    let address = "\(brewery.street ?? ""), \(brewery.city), \(brewery.stateProvince), \(brewery.postalCode), \(brewery.country)"
                    print(address)
                    reverseGeocodeRoute(address: address) // Replace with actual address
                }
            }) {
                Image(systemName: "map")
                    .foregroundColor(Color("Brew_Text")) // Assuming you have defined this color in your assets
                    .font(.title)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            Spacer()
            
            var backgroundColor: Color {
                switch imageCount {
                case 1...5:
                    return .green
                case 6:
                    return .red
                default:
                    return .gray
                }
            }

            if imageCount > 0 {
                Button(action: {
                    navigationManager.push(.breweryImageViewer, breweryId: brewery.id)
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "rectangle.grid.2x2.fill")
                            .foregroundColor(Color("Brew_Text"))
                        Text("\(imageCount)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(backgroundColor)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                    .font(.title)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            } else {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .foregroundColor(.gray)
                        .opacity(0.5)
                    Text("\(imageCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(backgroundColor)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
                .font(.title)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }

            Spacer()

            Button(action: {
                isCameraPresented = true
            }) {
                HStack {
                    Image(systemName: "camera")
                }
                .foregroundColor(Color("Brew_Text"))
                .font(.title)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(image: $image, sourceType: .camera)
                    .onDisappear {
                        if let image = image {
                            saveImage(image: image)
                            updateImageCount()
                        }
                    }
            }

            Spacer()
            Button(action: {
                isGalleryPresented = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                }
                .foregroundColor(Color("Brew_Text"))
                .font(.title)
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $isGalleryPresented) {
                ImagePicker(image: $image, sourceType: .photoLibrary)
                    .onDisappear {
                        if let image = image {
                            saveImage(image: image)
                            updateImageCount()
                        }
                    }
            }
            
            
            
            Spacer()
            
            let address = "\(brewery.street ?? ""), \(brewery.city), \(brewery.stateProvince), \(brewery.postalCode), \(brewery.country)"
            let shareText = """
            Brewery Name: \(brewery.name)
            Type: \(brewery.breweryType)
            Address: \(address)
            Phone: \(brewery.phone ?? "N/A")
            Website: \(brewery.websiteURL ?? "N/A")
            Coordinates: \(brewery.latitude), \(brewery.longitude)
            """
            ShareLink(item: shareText, subject: Text("Share brewery information."), message: Text(brewery.name)) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color("Brew_Text"))
                    .font(.title)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            loadFavoriteStatus()
            updateImageCount()
        }
    }
    
    func updateImageCount() {
            imageCount = BreweryStorage.shared.getImageCount(for: brewery.id)
        }

    
    private func saveImage(image: UIImage) {
            let id = UserDefaults.standard.string(forKey: "SelectedBreweryId") ?? ""
            do {
                try BreweryStorage.shared.saveBreweryImage(id: brewery.id, image: image)
                
                print("Image saved successfully.")
            } catch {
                alertMessage = "Failed to save image or maximum images reached."
                showAlert = true
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
    
    func reverseGeocodeRoute(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.coordinateRoute = location.coordinate
                    self.openMapsAppWithDirections(to: self.coordinateRoute!, destinationName: "Destination")
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Geocoding failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.coordinateRoute == nil {
                self.showAlert = true
                self.alertMessage = "Geocoding timed out."
            }
        }
    }
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName: String) {
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ] as [String : Any]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destinationName
        mapItem.openInMaps(launchOptions: options)
    }
}

struct BreweryMapDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BreweryMapDetailsView(brewery: BreweryMap(id: "4ffda196-dd59-44a5-9eeb-5f7fd4b58f5a", name: "Example Brewery", breweryType: "Large", address1: "123 Main St", city: "City", stateProvince: "State", postalCode: "12345", country: "Country", longitude: "0.0", latitude: "0.0", phone: nil, websiteURL: nil, state: "State", street: "123 Main St"))
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
