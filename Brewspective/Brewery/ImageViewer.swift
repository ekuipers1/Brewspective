//
//  Imageviewer.swift
//  Brewspective
//
//  Created by Erik Kuipers on 21.06.24.
//

import SwiftUI

struct ImageViewer: View {
    let breweryId: String
    @State private var images: [UIImage] = []
    @State private var showAlert = false
    @State private var indexToDelete: Int?
    @State private var selectedImage: UIImage?
    
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
                Text("Brewery Images")
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                    .frame(width: 40)
            }
            .frame(width: UIScreen.main.bounds.width, height: 60)
            .padding(.trailing, 20)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(Array(images.enumerated()), id: \.element) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: CGFloat.random(in: 150...250))
                                .cornerRadius(10)
                                .padding()
                                .onTapGesture {
                                    selectedImage = image
                                    navigationManager.push(.breweryImage, image: image)
                                }
                            
                            Button(action: {
                                indexToDelete = index
                                showAlert = true
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                                    .padding([.top, .trailing], 10)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            images = BreweryStorage.shared.getBreweryImages(by: breweryId)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Image"),
                message: Text("Are you sure you want to delete this image?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = indexToDelete {
                        deleteImage(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navigationManager.pop()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    private func deleteImage(at index: Int) {
        let imageName = "\(breweryId)_\(index + 1).jpg"
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        do {
            try fileManager.removeItem(at: fileURL)
            images.remove(at: index)
            // Update image names in storage
            for i in index..<images.count {
                let oldName = "\(breweryId)_\(i + 2).jpg"
                let newName = "\(breweryId)_\(i + 1).jpg"
                let oldURL = documentsDirectory.appendingPathComponent(oldName)
                let newURL = documentsDirectory.appendingPathComponent(newName)
                try fileManager.moveItem(at: oldURL, to: newURL)
            }
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
        }
    }
}


//
//
//#Preview {
//    ImageViewer()
//}
