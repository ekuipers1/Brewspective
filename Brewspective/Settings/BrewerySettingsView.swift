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
                                Spacer()
                                Text("What's new?")
                                    .foregroundColor(Color.Brew_Text)
                                Spacer()
                                
                            }
                            .frame(width: 100, height: 100) // Adjust size as needed
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
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.Brew_Text)
                                Spacer()
                                Text("Language")
                                    .foregroundColor(Color.Brew_Text)
                                Spacer()
                            }
                            .frame(width: 100, height: 100) // Adjust size as needed
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
                                Spacer()
                                Text("Privacy Policy")
                                    .foregroundColor(Color.Brew_Text)
                                Spacer()
                            }
                            .frame(width: 100, height: 100) // Adjust size as needed
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
    
    var body: some View {
        List(icons, id: \.self) { iconName in
            HStack {
                Image(uiImage: UIImage(named: iconName) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                Text(iconName)
                    .padding(.leading, 10)
                
                Spacer()
                
                if selectedIcon == iconName {
                    Image(systemName: "checkmark")
                }
            }.listRowBackground(Color.clear)
            
                .onTapGesture {
                    UIApplication.shared.setAlternateIconName(iconName == "Brespective" ? nil : iconName) { error in
                        if let error = error {
                            print("Error changing app icon: \(error.localizedDescription)")
                        } else {
                            selectedIcon = iconName
                        }
                    }
                }
        }.scrollContentBackground(.hidden)
        
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
