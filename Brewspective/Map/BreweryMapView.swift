//
//  BreweryMapView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//


import SwiftUI
import MapKit

struct BreweryMapView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = BreweryMapViewModel()
    @State private var selectedBrewery: BreweryMap? = nil
    @State private var selectedPerPageIndex = 0
    let perPageOptions = [25, 50, 75, 100, 150, 200]
    @State private var isExpanded = false
    @State private var showingIconDetails = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $viewModel.userTrackingMode, annotationItems: viewModel.breweries) { brewery in
                MapAnnotation(coordinate: brewery.coordinate) {
                    CustomMapAnnotation(brewery: brewery) {
                        selectedBrewery = brewery
                        UserDefaults.standard.set(brewery.id, forKey: "SelectedBreweryId")
                    }
                }
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
                // Fetch breweries initially
                if let userLocation = viewModel.getCurrentLocation() {
                    viewModel.fetchBreweries(at: userLocation, updateRegion: true)
                }
            }
            .accentColor(.blue)
            .sheet(item: $selectedBrewery) { brewery in
                BreweryMapDetailsView(brewery: brewery)
                    .presentationDetents([.height(500)])
            }
            
            VStack {
                HStack {
                    ZStack {
                        Button(action: {
                            navigationManager.pop()
                        }) {
                            Image(systemName: "arrow.left")
                                .leftArrowMap()
                        }
                        .padding(5)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        .padding(16)
                        .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {
                        showingIconDetails.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .leftArrowMap()
                    }
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .padding(16)
                    .foregroundColor(.black)
                    .sheet(isPresented: $showingIconDetails) {
                        MapHelpView(showingIconDetails: $showingIconDetails)
                    }
                }.frame(width: UIScreen.main.bounds.width, height: 60)
                Spacer()
                
                HStack {
                    Text("Results per call")
                        .frame(maxWidth: 120, maxHeight: 25)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Picker(selection: $selectedPerPageIndex, label: Text("")) {
                        ForEach(0..<perPageOptions.count) { index in
                            VStack {
                                Text("\(perPageOptions[index])")
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedPerPageIndex) { _ in
                        viewModel.fetchBreweries(at: viewModel.region.center, perPage: perPageOptions[selectedPerPageIndex])
                    }
                    .frame(maxWidth: 80, maxHeight: 25)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    
                    Button(action: {
                        viewModel.fetchBreweries(at: viewModel.region.center, updateRegion: false)
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding(16)
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct MapHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showingIconDetails: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 20) {
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
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 60)
            .padding(.top, 40)
            
            Text("Adjusting the amount in 'Results per call' will automatically update the number of breweries displayed on the map.")
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
                                }
                                .padding(.leading, 10)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 80)
                }
                .frame(maxHeight: 350)
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
        }
        .padding()
    }
}

class BreweryMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion()
    @Published var userTrackingMode: MapUserTrackingMode = .follow
    private var locationManager = CLLocationManager()
    @Published var breweries: [BreweryMap] = []
    @Published var selectedPerPageIndex = 0
    let perPageOptions = [25, 50, 75, 100, 200]
    private var initialLocationSet = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Handle location services not enabled scenario
        }
    }
    
    func fetchBreweries(at location: CLLocationCoordinate2D? = nil, perPage: Int? = nil, updateRegion: Bool = false) {
        let coordinate = location ?? locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let perPage = perPage ?? perPageOptions[selectedPerPageIndex] // Use selectedPerPageIndex if perPage is not provided
        let urlString = "https://api.openbrewerydb.org/v1/breweries?by_dist=\(coordinate.latitude),\(coordinate.longitude)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching breweries: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let breweries = try JSONDecoder().decode([BreweryMap].self, from: data)
                DispatchQueue.main.async {
                    self.breweries = breweries
                    if updateRegion {
                        self.updateMapRegion(to: coordinate)
                    }
                }
            } catch {
                print("Error decoding breweries: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        if !initialLocationSet {
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.userTrackingMode = .none
                self.fetchBreweries(at: latestLocation.coordinate, updateRegion: true)
                self.initialLocationSet = true
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func updateMapRegion(to coordinate: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.region = coordinateRegion
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
}






//class BreweryMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
//    @Published var region = MKCoordinateRegion()
//    @Published var userTrackingMode: MapUserTrackingMode = .follow
//    private var locationManager = CLLocationManager()
//    @Published var breweries: [BreweryMap] = []
//    @Published var selectedPerPageIndex = 0
//    let perPageOptions = [25, 50, 75, 100, 200]
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//    }
//    
//    func checkIfLocationServicesIsEnabled() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.requestWhenInUseAuthorization()
//        } else {
//            // Handle location services not enabled scenario
//        }
//    }
//    
//    func fetchBreweries(at location: CLLocationCoordinate2D? = nil, perPage: Int? = nil) {
//        let coordinate = location ?? locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
//        let perPage = perPage ?? perPageOptions[selectedPerPageIndex] // Use selectedPerPageIndex if perPage is not provided
//        let urlString = "https://api.openbrewerydb.org/v1/breweries?by_dist=\(coordinate.latitude),\(coordinate.longitude)&per_page=\(perPage)"
//        guard let url = URL(string: urlString) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error fetching breweries: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            do {
//                let breweries = try JSONDecoder().decode([BreweryMap].self, from: data)
//                DispatchQueue.main.async {
//                    self.breweries = breweries
//                    self.updateMapRegion()
//                }
//            } catch {
//                print("Error decoding breweries: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let latestLocation = locations.first else { return }
//        DispatchQueue.main.async {
//            self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//            self.userTrackingMode = .none
//        }
//    }
//    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .notDetermined, .restricted, .denied:
//            break
//        case .authorizedAlways, .authorizedWhenInUse:
//            locationManager.startUpdatingLocation()
//        @unknown default:
//            break
//        }
//    }
//    
//    private func updateMapRegion() {
//        guard breweries.isEmpty else { return }
//        
//        if let userLocation = locationManager.location {
//            DispatchQueue.main.async {
//                let coordinateRegion = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//                self.region = coordinateRegion
//            }
//        }
//    }
//}

struct BreweryMap: Codable, Identifiable {
    var id: String
    var name: String
    var breweryType: String
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String
    var stateProvince: String
    var postalCode: String
    var country: String
    var longitude: String
    var latitude: String
    var phone: String?
    var websiteURL: String?
    var state: String
    var street: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breweryType = "brewery_type"
        case address1 = "address_1"
        case address2 = "address_2"
        case address3 = "address_3"
        case city
        case stateProvince = "state_province"
        case postalCode = "postal_code"
        case country
        case longitude
        case latitude
        case phone
        case websiteURL = "website_url"
        case state
        case street
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double(latitude) ?? 0, longitude: Double(longitude) ?? 0)
    }
}


#Preview {
    BreweryMapView()
}


struct CustomMapAnnotation: View {
    var brewery: BreweryMap
    var onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            Image(systemName: IconUtility.icon(for: brewery.breweryType))
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.black)
        }
        .onTapGesture {
            onTap()
        }
    }
}
