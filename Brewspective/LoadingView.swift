//
//  LoadingView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 13.06.24.
//

import SwiftUI

struct LoadingView: View {
    @State private var fillLevel: CGFloat = 0.0
    
    var body: some View {
        
        VStack(){
            ZStack {
                
                BeerGlassHandleShape()
                    .stroke(lineWidth: 8)
                    .foregroundColor(.black)
                
                BeerGlassShape()
                    .fill(Color.white)
                
                BeerGlassShape()
                    .stroke(lineWidth: 8)
                    .foregroundColor(.black)
                
                
                
                ZStack(){
                    
                    BeerGlassShape()
                        .fill(Color.yellow)
                        .mask(
                            Rectangle()
                                .scaleEffect(y: fillLevel, anchor: .bottom)
                        )
                    
                    ForEach(0..<10) { _ in
                        Bubble()
                    }.offset(y: 100)
                    
                }
            }
            .frame(width: 250, height: 300)
            
            Text("Please wait while we load the content.")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3)) {
                fillLevel = 0.8
            }
        }
 
    }
}

#Preview {
    LoadingView()
}
