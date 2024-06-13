//
//  UpdateEstablishmentView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 27.05.24.
//

import SwiftUI
import MessageUI
import CoreLocation

struct UpdateEstablishmentView: View {
    @State private var breweryId: String = ""
    @State private var name: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var stateOrProvince: String = ""
    @State private var postalCode: String = ""
    @State private var country: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    @State private var selectedType: String = "micro"
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State private var submitterType: String = "Owner"
    @State private var hasPermission: Bool = false
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    let types = [
        ("micro", "Most craft breweries. For example, Samual Adams is still considered a micro brewery."),
        ("nano", "An extremely small brewery which typically only distributes locally."),
        ("regional", "A regional location of an expanded brewery. Ex. Sierra Nevada’s Asheville, NC location."),
        ("brewpub", "A beer-focused restaurant or restaurant/bar with a brewery on-premise."),
        ("large", "A very large brewery. Likely not for visitors. Ex. Miller-Coors."),
        ("planning", "A brewery in planning or not yet opened to the public."),
        ("bar", "A bar. No brewery equipment on premise."),
        ("contract", "A brewery that uses another brewery’s equipment."),
        ("proprietor", "Similar to contract brewing but refers more to a brewery incubator."),
        ("closed", "A closed brewery")
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
                .padding(.trailing, 20)
                
                Spacer()
                Text("Update an Establishment")
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }.padding(.horizontal)
                .frame(maxWidth: .infinity)
            
            Form {
                Section(header: Text("Establishment Information")) {
                    TextField("Name of the Establishment", text: $name)
                    TextField("Street", text: $street)
                    TextField("City", text: $city)
                    TextField("State / Province", text: $stateOrProvince)
                    TextField("Postal Code", text: $postalCode)
                    TextField("Country", text: $country)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Website", text: $website)
                }
                
                Picker("Type of Establishment", selection: $selectedType) {
                    ForEach(types, id: \.0) { type in
                        Text(type.0.capitalized).tag(type.0)
                    }
                }
                
                Section(header: Text("Submitter Information")) {
                    Picker("Are you the owner?", selection: $submitterType) {
                        Text("Owner").tag("Owner")
                        Text("Individual").tag("Individual")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if submitterType == "Individual" {
                        Toggle("Do you have permission from the owner?", isOn: $hasPermission)
                    }
                }
                
                Button("Submit") {
                    sendEmail()
                }
            }.navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingMailView) {
            if MFMailComposeViewController.canSendMail() {
                MailView(
                    result: $result,
                    subject: "Update Establishment Information",
                    recipients: ["brew_update@eckodesign.eu"],
                    messageBody: emailMessage(),
                    onDismiss: {
                        navigationManager.pop()
                    }
                )
            } else {
                Text("Can't send emails from this device")
            }
            
        }
        .onAppear {
            fetchBreweryDetail()
        }
    }
    
    func fetchBreweryDetail() {
        guard let usebreweryid = UserDefaults.standard.string(forKey: "SelectedBreweryId") else {
            print("SelectedBreweryId is nil")
            return
        }
        
        let breweryId = usebreweryid.replacingOccurrences(of: "\"", with: "")
        guard let url = URL(string: "https://api.openbrewerydb.org/breweries/\(breweryId)") else {
            print("Invalid URL")
            return
        }
        
        print("Fetching brewery detail from URL:", url)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(BreweryDetail.self, from: data) {
                    DispatchQueue.main.async {
                        name = decodedResponse.name
                        selectedType = decodedResponse.brewery_type
                        street = decodedResponse.street ?? ""
                        city = decodedResponse.city ?? ""
                        stateOrProvince = decodedResponse.state_province ?? ""
                        postalCode = decodedResponse.postal_code ?? ""
                        country = decodedResponse.country ?? ""
                        phoneNumber = decodedResponse.phone ?? ""
                        website = decodedResponse.website_url ?? ""
                    }
                } else {
                    print("Failed to decode brewery detail")
                    DispatchQueue.main.async {
                        selectedType = ""
                    }
                }
            } else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    selectedType = ""
                }
            }
        }.resume()
    }
    
    
    func geocodeAddress() {
        let address = "\(street), \(city), \(stateOrProvince), \(postalCode), \(country)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
            } else if let placemark = placemarks?.first {
                self.latitude = placemark.location?.coordinate.latitude
                self.longitude = placemark.location?.coordinate.longitude
            }
            self.sendEmail()
        }
    }
    
    func emailMessage() -> String {
               """
               Name: \(name)
               Street: \(street)
               City: \(city)
               State/Province: \(stateOrProvince)
               Postal Code: \(postalCode)
               Country: \(country)
               Phone: \(phoneNumber)
               Website: \(website)
               Type: \(selectedType)
               Description: \(types.first { $0.0 == selectedType }?.1 ?? "")
               Submitter Type: \(submitterType)
               Permission: \(submitterType == "Individual" ? (hasPermission ? "Yes" : "No") : "N/A")
               """
    }
    
    func sendEmail() {
        isShowingMailView = true
    }
}

#Preview {
    UpdateEstablishmentView()
}


