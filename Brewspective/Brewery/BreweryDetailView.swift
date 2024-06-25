//
//  BreweryDetailView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//


import MapKit
import SwiftUI
import CoreLocation
    
struct BreweryDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    var breweryId: String
    @State private var isCameraPresented = false
    @State private var isGalleryPresented = false
    @State private var image: UIImage? = nil
    @State private var imageCount = 0
    @State private var isFetching = false
    @State private var dataFetchError = false
    @State private var geocodingError = false
    @State private var mapFetchError = false
    @State private var coordinate: IdentifiableCoordinate?
    @State private var coordinateRoute: CLLocationCoordinate2D?
    @State private var showingDataOptions = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isHeartFilled = false
   // @State private var brewery: Brewery?
    @State private var brewery: BreweryDetail?

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
                                    .foregroundColor(Color("Brew_Text"))
                                    .font(.title)
                                Link(phone, destination: URL(string: "tel:\(phone)")!)
                                    .foregroundColor(Color("Brew_Text"))
                                    .font(.title2)
                                Spacer()
                            }
                            .padding(.leading, 20)
                        }

                        HStack {
                            if let website = brewery.website_url {
                                Image(systemName: "link.circle")
                                    .foregroundColor(Color("Brew_Text"))
                                    .font(.title)
                                Link("Website", destination: URL(string: website)!)
                                    .foregroundColor(Color("Brew_Text"))
                                    .font(.title2)
                                    .underline()
                            }

                            Spacer()
                            Image(systemName: IconUtility.icon(for: brewery.brewery_type))
                                .font(.title)
                                .padding(.trailing, 20)
                        }
                        .padding(.leading, 20)
                    } else if dataFetchError {
                        Text("Failed to load data. Please try again.")
                            .foregroundColor(.red)
                            .padding()
                        Button(action: {
                            fetchBreweryDetail()
                        }) {
                            Text("Retry")
                                .foregroundColor(.blue)
                        }
                    } else {
                        Text(isFetching ? "Loading..." : "Fetching data...")
                    }
                }
                .navigationBarHidden(true)

                if dataFetchError {
                    EmptyView() // Hide map-related views when data fetch fails
                } else if let coordinate = coordinate {
                    BreweryMapViewDetail(coordinate: coordinate)
                        .frame(height: geometry.size.height / 2)
                        .padding(.bottom, 20)
                } else if geocodingError {
                    Text("Unable to determine location")
                        .frame(height: 200)
                } else if mapFetchError {
                    Text("Failed to load map. Please try again.")
                        .foregroundColor(.red)
                        .padding()
                    Button(action: {
                        updateMapView(for: brewery!)
                    }) {
                        Text("Retry")
                            .foregroundColor(.blue)
                    }
                } else {
                    Text(isFetching ? "Loading Map..." : "Fetching map data...")
                        .frame(height: 200)
                }

                HStack {
                    Button(action: {
                        if let latitudeString = brewery?.latitude,
                           let longitudeString = brewery?.longitude,
                           let latitude = CLLocationDegrees(latitudeString),
                           let longitude = CLLocationDegrees(longitudeString) {
                            openMapsAppWithDirections(to: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), destinationName: "Destination")
                        } else {
                            let address = "\(brewery?.street ?? ""), \(brewery?.city ?? ""), \(brewery?.state_province ?? ""), \(brewery?.postal_code ?? ""), \(brewery?.country ?? "")"
                            reverseGeocodeRoute(address: address) // Replace with actual address
                        }
                    }) {
                        Image(systemName: "map")
                            .foregroundColor(Color("Brew_Text"))
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
                            navigationManager.push(.breweryImageViewer, breweryId: breweryId)
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

                    let address = "\(brewery?.street ?? ""), \(brewery?.city ?? ""), \(brewery?.state_province ?? ""), \(brewery?.postal_code ?? ""), \(brewery?.country ?? "")"
                    let shareText = """
                    Brewery Name: \(brewery?.name ?? "")
                    Type: \(brewery?.brewery_type ?? "")
                    Address: \(address)
                    Phone: \(brewery?.phone ?? "N/A")
                    Website: \(brewery?.website_url ?? "N/A")
                    Coordinates: \(brewery?.latitude ?? "N/A"), \(brewery?.longitude ?? "N/A")
                    """
                    ShareLink(item: shareText, subject: Text("Share brewery information."), message: Text(brewery?.name ?? "")) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color("Brew_Text"))
                            .font(.title)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .onAppear {
                fetchBreweryDetail()
                loadFavoriteStatus()
                updateImageCount()
            }
        }
    }
    
    func updateImageCount() {
            imageCount = BreweryStorage.shared.getImageCount(for: breweryId)
        }

    private func saveImage(image: UIImage) {
            let id = UserDefaults.standard.string(forKey: "SelectedBreweryId") ?? ""
            do {
                try BreweryStorage.shared.saveBreweryImage(id: id, image: image)
                
                print("Image saved successfully.")
            } catch {
                alertMessage = "Failed to save image or maximum images reached."
                showAlert = true
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
        isFetching = true
        dataFetchError = false
        
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
                        self.isFetching = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dataFetchError = true
                        self.isFetching = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.dataFetchError = true
                    self.isFetching = false
                }
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
        
        // Timeout for fetching data
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isFetching {
                self.dataFetchError = true
                self.isFetching = false
            }
        }
    }
    
    func updateMapView(for brewery: BreweryDetail) {
        if let latitude = brewery.latitude, let longitude = brewery.longitude, let lat = Double(latitude), let lon = Double(longitude) {
            self.coordinate = IdentifiableCoordinate(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        } else {
            let address = "\(brewery.street ?? ""), \(brewery.city ?? ""), \(brewery.state_province ?? "")"
            reverseGeocode(address: address)
        }
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
    
    
    func reverseGeocode(address: String) {
        mapFetchError = false
        geocodingError = false
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    self.coordinate = IdentifiableCoordinate(coordinate: location.coordinate)
                    self.geocodingError = false
                    self.mapFetchError = false
                }
            } else {
                DispatchQueue.main.async {
                    self.geocodingError = true
                    self.mapFetchError = true
                }
                print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        // Timeout for fetching map data
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.coordinate == nil {
                self.geocodingError = true
                self.mapFetchError = true
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

#Preview {
    BreweryDetailView(breweryId: "b54b16e1-ac3b-4bff-a11f-f7ae9ddc27e0")
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }
    }
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
            .padding(.horizontal, 20)
    }
}

struct DetailViewHelp: View {
    let breweryId: String
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isExpanded = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
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
                        .frame(width: geometry.size.width - 80)
                    }
                    .frame(maxHeight: geometry.size.height * 0.4) // Adjust this percentage as needed
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
                
                HStack {
                    Button("Update Establishment") {
                        navigationManager.push(.brewerySettingsUpdate)
                    }
                    .padding()
                    .font(.title3)
                    .foregroundColor(.brewTextInf)
                    .background(Color.brewText)
                    .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding()
        }
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
                            UIPasteboard.general.string = combinedText
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










