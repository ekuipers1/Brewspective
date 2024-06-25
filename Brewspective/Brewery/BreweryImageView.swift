//
//  BreweryImageView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 21.06.24.
//

import SwiftUI

struct BreweryImageView: View {
    let image: UIImage
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack {
            HStack {
                       Button(action: {
                           navigationManager.pop()
                       }) {
                           Image(systemName: "arrow.left")
                               .leftArrow()
                               .padding(.leading, 20)
                       }
                       Spacer()
                       Text("Brewery Image")
                           .font(.title)
                           .lineLimit(1)
                           .minimumScaleFactor(0.5)
                           .frame(maxWidth: .infinity, alignment: .center)
                       Spacer()
                           .frame(width: 40)
                   }
                   .frame(width: UIScreen.main.bounds.width, height: 60)
                   .padding(.trailing, 20)
            
            Spacer()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct BreweryImageView_Previews: PreviewProvider {
    static var previews: some View {
        let navigationManager = NavigationManager()
        let sampleImage = UIImage(systemName: "photo")! // Replace with a real UIImage for a more accurate preview
        
        BreweryImageView(image: sampleImage)
            .environmentObject(navigationManager)
    }
}

