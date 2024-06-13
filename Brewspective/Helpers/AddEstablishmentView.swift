//
//  AddEstablishmentView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 13.05.24.
//

import SwiftUI
import MessageUI
import CoreLocation


struct AddEstablishmentView: View {
    @State private var name: String = ""
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var stateOrProvince: String = ""
    @State private var postalCode: String = ""
    @State private var country: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    @State private var selectedType: String = "Micro"
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State private var submitterType: String = "Owner"
    @State private var hasPermission: Bool = false
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    let types = [
        ("Micro", "Most craft breweries. For example, Samual Adams is still considered a micro brewery."),
        ("Nano", "An extremely small brewery which typically only distributes locally."),
        ("Regional", "A regional location of an expanded brewery. Ex. Sierra Nevada’s Asheville, NC location."),
        ("Brewpub", "A beer-focused restaurant or restaurant/bar with a brewery on-premise."),
        ("Large", "A very large brewery. Likely not for visitors. Ex. Miller-Coors."),
        ("Planning", "A brewery in planning or not yet opened to the public."),
        ("Bar", "A bar. No brewery equipment on premise."),
        ("Contract", "A brewery that uses another brewery’s equipment."),
        ("Proprietor", "Similar to contract brewing but refers more to a brewery incubator.")
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
                Text("Add an Establishment")
                    .font(.title)
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
                        Text(type.0).tag(type.0)
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
                    subject: "New Establishment Information",
                    recipients: ["brew_new@eckodesign.eu"],
                    messageBody: emailMessage(),
                    onDismiss: {
                        navigationManager.pop()
                    }
                )
            } else {
                Text("Can't send emails from this device")
            }
        }
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

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var result: Binding<Result<MFMailComposeResult, Error>?>
    var subject: String
    var recipients: [String]
    var messageBody: String
    var onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = context.coordinator
        mailVC.setSubject(subject)
        mailVC.setToRecipients(recipients)
        mailVC.setMessageBody(messageBody, isHTML: false)
        return mailVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
            parent.result.wrappedValue = .success(result)
            parent.onDismiss()
        }
    }
}

struct AddEstablishmentView_Previews: PreviewProvider {
    static var previews: some View {
        AddEstablishmentView()
    }
}
