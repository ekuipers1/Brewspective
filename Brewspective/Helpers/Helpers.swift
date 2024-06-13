//
//  Helpers.swift
//  Brewspective
//
//  Created by Erik Kuipers on 26.04.24.
//

import Foundation
import SwiftUI

extension Color {

    static let Brew_Text = Color("Brew_Text")
    static let Brew_Text_Inf = Color("Brew_Text_Inf")
    static let Brew_Blocks = Color("Brew_Blocks")

}

struct TransparentGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.Brew_Blocks))
            .overlay(configuration.label.padding(.leading, 4), alignment: .topLeading)
    }
}


extension Image {
    
    func leftArrow() -> some View {
        self
            .padding(.leading, 15.0)
            .font(.title)
            .frame(width: 40.0, height: 40.0)
            .foregroundColor(Color.Brew_Text)
            .cornerRadius(50)
    }
    
    func leftArrowMap() -> some View {
        self
            .font(.title)
            .frame(width: 40.0, height: 40.0)
            .foregroundColor(Color.black)
            .cornerRadius(50)
    }
    
    func heart() -> some View {
        self
            .font(.title)
            .frame(width: 40.0, height: 40.0)
    }
    
    func hamburgerMenu() -> some View {
        self
            .padding(.trailing, 15.0)
            .font(.title)
            .frame(width: 40.0, height: 40.0)
            .foregroundColor(Color.red)
    }
}


struct IconUtility {
    static func icon(for type: String) -> String {
        switch type {
        case "micro": return "house.fill"
        case "nano": return "leaf.fill"
        case "regional": return "map.fill"
        case "brewpub": return "person.2.fill"
        case "large": return "shippingbox.fill"
        case "planning": return "hammer.fill"
        case "bar": return "music.note.house.fill"
        case "contract": return "signature"
        case "taproom": return "square.split.bottomrightquarter.fill"
        case "proprietor": return "building.2.fill"
        case "closed": return "xmark.square.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

func getAppVersion() -> String {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    return "Version \(version) (\(build))"
}


let widthFull = UIScreen.main.bounds.width - 20