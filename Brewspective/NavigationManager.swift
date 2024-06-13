//
//  NavigationManager.swift
//  Brewspective
//
//  Created by Erik Kuipers on 25.04.24.
//

import Combine

class NavigationManager: ObservableObject {
    @Published private(set) var viewStack: [ViewName] = [.home]
    @Published var selectedBreweryId: String?
    @Published var selectedCountry: Country?
    @Published var selectedIcon: IconInfo?
    
    
    func push(_ view: ViewName, breweryId: String? = nil, icon: IconInfo? = nil) {
        if let id = breweryId {
            selectedBreweryId = id
        }
        if let icon = icon {
            selectedIcon = icon
        }
        viewStack.append(view)
        objectWillChange.send()
    }
    
    func pop() {
        if viewStack.count > 1 {
            _ = viewStack.popLast()
            print("Popped view: \(viewStack.last ?? .home)")
            objectWillChange.send()
        }
    }
    
    func popTo(_ view: ViewName) {
        while viewStack.count > 1, viewStack.last != view {
            _ = viewStack.popLast()
        }
        objectWillChange.send()
    }
    
    var currentView: ViewName {
        viewStack.last ?? .home
    }
    
    func navigateTo(_ view: ViewName) {
        viewStack = [view]
        objectWillChange.send()
    }
    
    enum ViewName {
        case home
        case breweryAll
        case breweryFav
        case breweryType
        case breweryMap
        case brewerySettings
        case brewerySettingsAdd
        case brewerySettingsUpdate
        case breweryDetail
        case breweryCountry
        case breweryCountryDetail
        case breweryTypeViewDetail
    }
}
