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


struct BeerGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topWidth = rect.width * 0.9
        let bottomWidth = rect.width * 0.6
        let glassHeight = rect.height * 0.9

        // Draw the main body of the beer glass
        path.move(to: CGPoint(x: (rect.width - topWidth) / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: (rect.width + topWidth) / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: (rect.width + bottomWidth) / 2, y: glassHeight))
        path.addLine(to: CGPoint(x: (rect.width - bottomWidth) / 2, y: glassHeight))
        path.closeSubpath()

        return path
    }
}

struct BeerGlassHandleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let handleWidth: CGFloat = rect.width * 0.33
        let handleHeight: CGFloat = rect.height * 0.4

        // Draw the handle
        path.move(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.width * 0.75 + handleWidth, y: rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.width * 0.75 + handleWidth, y: rect.height * 0.25 + handleHeight))
        path.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.25 + handleHeight))
        path.closeSubpath()

        return path
    }
}

struct Bubble: View {
    @State private var offset: CGFloat = .random(in: 0...1)
    @State private var opacity: Double = .random(in: 0.3...0.6)

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: 10, height: 10)
            .offset(x: .random(in: -20...20), y: offset * -150)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: .random(in: 2...4)).repeatForever(autoreverses: false)) {
                    offset = 1
                }
            }
    }
}

