//
//  LoadingView.swift
//  Brewspective
//
//  Created by Erik Kuipers on 13.06.24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Text("Please wait while we load the content.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    LoadingView()
}
