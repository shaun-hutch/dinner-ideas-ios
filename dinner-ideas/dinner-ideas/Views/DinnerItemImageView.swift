//
//  DinnerItemImageView.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 01/02/2025.
//

import SwiftUI
import PhotosUI
import AVFoundation
import ImagePlayground

struct DinnerItemImageView: View {
    let canEdit: Bool
    @Binding var imageGenerationConcept: String
    @Binding var selectedImage: UIImage?
    
    @State var selectedItem: PhotosPickerItem? = nil
    @State var isShowingCamera: Bool = false
    @State var isShowingPicker: Bool = false
    @State var isShowingImagePlayground: Bool = false
    @State private var isShowingPermissionAlert = false
    @State private var showingImageActionSheet = false
    
    @Environment(\.supportsImagePlayground) var supportsImagePlayground
    
    var body: some View {
        ZStack {
            // Image display
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(.quaternary.opacity(0.3))
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                
                                if canEdit {
                                    Text("Add Photo")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Tap to add an image")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                        
                                    Button("Choose Photo") {
                                        showingImageActionSheet = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    .padding(.top, 8)
                                } else {
                                    Text("No Image")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            }
            .onTapGesture {
                if canEdit {
                    showingImageActionSheet = true
                }
            }
            
            // Edit overlay when editing is enabled - add visual indicator for existing images
            if canEdit && selectedImage != nil {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showingImageActionSheet = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .background(.ultraThinMaterial, in: .circle)
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
        }
        .alert("Camera Permission Denied", isPresented: $isShowingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to take photos.")
        }
        .photosPicker(
            isPresented: $isShowingPicker,
            selection: $selectedItem,
            matching: .images,
            preferredItemEncoding: .automatic
        )
        .task(id: selectedItem) {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
            }
        }
        .imagePlaygroundSheet(
            isPresented: $isShowingImagePlayground,
            concept: imageGenerationConcept
        ) { url in
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
            }
        }
        .confirmationDialog(selectedImage != nil ? "Edit Photo" : "Add Photo", isPresented: $showingImageActionSheet, titleVisibility: .visible) {
            Button("Take Photo") {
                Task {
                    await checkCameraPermission()
                }
            }
            
            Button("Choose from Library") {
                isShowingPicker = true
            }
            
            if supportsImagePlayground {
                Button("Generate with AI") {
                    isShowingImagePlayground = true
                }
            }
            
            if selectedImage != nil {
                Button("Remove Photo", role: .destructive) {
                    withAnimation(.bouncy) {
                        selectedImage = nil
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    @ViewBuilder
    private func ContextMenuContent() -> some View {
        Button(action: {
            Task {
                await checkCameraPermission()
            }
        }) {
            Label("Take Photo", systemImage: "camera")
        }
        
        Button(action: {
            isShowingPicker = true
        }) {
            Label("Choose from Library", systemImage: "photo.on.rectangle")
        }
        
        if supportsImagePlayground {
            Button(action: {
                isShowingImagePlayground = true
            }) {
                Label("Generate Image", systemImage: "apple.image.playground")
            }
        }
        
        if selectedImage != nil {
            Divider()
            Button(role: .destructive, action: {
                withAnimation(.bouncy) {
                    selectedImage = nil
                }
            }) {
                Label("Remove Image", systemImage: "trash")
            }
        }
    }
    
    private func checkCameraPermission() async {
        guard await isAuthorized else {
            isShowingPermissionAlert = true
            return
        }
        
        isShowingCamera = true
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
}

#Preview {
    DinnerItemImageView(canEdit: true, imageGenerationConcept: .constant("Chicken Salad"), selectedImage: .constant(UIImage(systemName: "person.circle")!))
}
