//
//  BrewspectiveApp.swift
//  Brewspective
//
//  Created by Erik Kuipers on 24.04.24.
//

import SwiftUI

@main
struct BrewspectiveApp: App {
    
    @StateObject var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .environmentObject(navigationManager)
        }
    }
}
