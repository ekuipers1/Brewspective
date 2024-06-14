//
//  BrewerySettingsView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 26.04.24.
//

import SwiftUI

struct BrewerySettingsView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isIconSelectorVisible: Bool = false
    @State private var isLanguageSelectorVisible: Bool = false
    @State private var showingPicker: Bool = false
    @State private var selectedLanguage: String = ""
    @State private var languages: [String] = ["English", "Spanish", "German"] // Example languages
    @State private var isWhatsNewSheetVisible: Bool = false
    @State private var isPrivacySheetVisible: Bool = false
    
    
    var body: some View {
        
        VStack {
            HStack {
                Button(action: {
                    navigationManager.pop()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(Color.Brew_Text)//
                }
                Spacer()
                
                Text("Settings")
                    .font(.title)
                    .padding(.trailing, 40)
                Spacer()
            }
            .frame(width:widthFull, height: 60)
            
            
            ScrollView{
                
                VStack(){
                    
                    Spacer()
                    DisclosureGroup("Change App Icon", isExpanded: $isIconSelectorVisible) {
                        IconSelectionView()
                            .frame(height: 300)
                            .background(Color.clear)
                        
                    }
                    .background(Color.clear)
                    .foregroundColor(Color.Brew_Text)
                    .padding()
                    Spacer()
                        .onTapGesture {
                            isIconSelectorVisible.toggle()
                        }
                    
                    HStack(spacing: 20) { // Adjust spacing as needed
                        Button(action: {
                            isWhatsNewSheetVisible.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName: "megaphone")
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                Spacer()
                                Text("What's new?")
                                    .foregroundColor(Color.Brew_Text)
                                    .frame(width: 80)
                                Spacer()
                                
                            }
                            .frame(width: 110, height: 110) // Adjust size as needed
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName: "globe")
//                                    .fontWeight(.bold)
                                    .font(.title)
                                    .foregroundColor(Color.Brew_Text)
                                Spacer()
                                Text("Language")
                                    .foregroundColor(Color.Brew_Text)
                                    .frame(width: 80)
                                Spacer()
                            }
                            .frame(width: 110, height: 110) // Adjust size as needed
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isPrivacySheetVisible.toggle()
                        }) {
                            VStack {
                                Spacer()
                                Image(systemName: "lock.shield")
                                    .foregroundColor(Color.Brew_Text)
                                    .font(.title)
                                
                                Spacer()
                                Text("Privacy Policy")
                                    .foregroundColor(Color.Brew_Text)
                                    .frame(width: 80)
                                Spacer()
                            }
                            .frame(width: 110, height: 110) // Adjust size as needed
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    .sheet(isPresented: $isWhatsNewSheetVisible) {
                        WhatsNewView()
                    }
                    .sheet(isPresented: $isPrivacySheetVisible) {
                        PrivacyView()
                    }
                    
                    
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Data provided by")
                                .padding(.top, 20)
                            Link(destination: URL(string: "https://www.openbrewerydb.org")!) {
                                HStack {
                                    Text("Open Brewery DB")
                                    Image("logo")
                                        .resizable()
                                        .frame(width: 60, height: 35)
                                }
                            }
                            
                            Text("App development and design by")
                                .padding(.top, 20)
                            Link(destination: URL(string: "https://eckodesign.eu/portfolio/beerspective-ios-application/")!) {
                                Text("ECKO Design")
                                    .padding(.top, 10)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    
                    
                    Text("If you are aware of a brewery or own an establishment that is not listed in the app, you can click this button to complete a request form.")
                        .padding()
                    
                    Button("Add Establishment") {
                        navigationManager.push(.brewerySettingsAdd)
                    }
                    .padding()
                    .font(.title3)
                    .foregroundColor(.brewTextInf)
                    .background(Color.brewText)
                    .cornerRadius(10)
                }
                
            }
            Text(getAppVersion())
                .font(.callout)
            
            
        }
        .padding(.bottom, 50)
        .navigationBarHidden(true)
    }
}


#Preview {
    BrewerySettingsView()
}


struct IconSelectionView: View {
    let icons: [String] = ["Hop", "Brespective", "Beer Map", "Beer Mugs"]
    @State private var selectedIcon: String?
    
    let columns = [
            GridItem(.fixed(120)),
            GridItem(.fixed(120))
        ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(icons, id: \.self) { iconName in
                    VStack {
                        Image(uiImage: UIImage(named: iconName) ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                        
                        Text(iconName)
                            .padding(.top, 5)
                        
                        if selectedIcon == iconName {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .background(Color(UIColor.white))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onTapGesture {
                        UIApplication.shared.setAlternateIconName(iconName == "Brespective" ? nil : iconName) { error in
                            if let error = error {
                                print("Error changing app icon: \(error.localizedDescription)")
                            } else {
                                selectedIcon = iconName
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}




struct WhatsNewView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("What's New?")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading) {
                VersionRow(version: "V 1.0.0 (1)", description: "Initial Build")
                VersionRow(version: "V 1.0.1 (2)", description: "Added Spanish and German Language")
                VersionRow(version: "", description: "Added What's New section")
                VersionRow(version: "", description: "Added a Language switch to the settings section")
                VersionRow(version: "V 1.0.1 (3)", description: "Updated Splash Screen")
                VersionRow(version: "", description: "Updated Settings Page")
                VersionRow(version: "", description: "Updated Change Icon layout")
            }
            .padding()
            
            Spacer()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .font(.title3)
            .foregroundColor(.brewTextInf)
            .background(Color.brewText)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct VersionRow: View {
    var version: String
    var description: String
    
    var body: some View {
        VStack {
            Text(version)
                .frame(maxWidth: .infinity, alignment: .leading)
                .bold()
            Text(description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
        }
    }
}



struct PrivacyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var privacyPolicyText: String = "Loading..."
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Privacy Policy")
                    .font(.title)
                    .padding()
                
                Text(privacyPolicyText)
                    .padding()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            loadPrivacyPolicy()
        }
    }
    
    func loadPrivacyPolicy() {
        if let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "txt") {
            do {
                privacyPolicyText = try String(contentsOf: url, encoding: .utf8)
            } catch {
                privacyPolicyText = "Failed to load privacy policy."
            }
        } else {
            privacyPolicyText = "Privacy policy file not found."
        }
    }
}
