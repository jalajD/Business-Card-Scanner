import SwiftUI

struct ScanBusinessCardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var showImagePicker = false
    @State private var showEditView = false
    @State private var isProcessing = false
    @State private var capturedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var parsedData: BusinessCardData?
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "creditcard.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)

                Text("Scan Business Card")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Take a photo or select from gallery to extract contact information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    Button(action: {
                        showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Take Photo")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Choose from Gallery")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)

                if isProcessing {
                    ProgressView("Processing image...")
                        .padding()
                }
            }
            .navigationTitle("New Scan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    processImage(image)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { image in
                    processImage(image)
                }
            }
            .sheet(isPresented: $showEditView) {
                if let image = capturedImage, let data = parsedData {
                    BusinessCardEditView(
                        name: data.name ?? "",
                        company: data.company ?? "",
                        jobTitle: data.jobTitle ?? "",
                        email: data.email ?? "",
                        phone: data.phone ?? "",
                        address: data.address ?? "",
                        website: data.website ?? "",
                        notes: "",
                        capturedImage: image,
                        rawText: recognizedText
                    )
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .onChange(of: showEditView) { newValue in
                if !newValue {
                    dismiss()
                }
            }
        }
    }

    private func processImage(_ image: UIImage) {
        capturedImage = image
        isProcessing = true

        TextRecognitionService.shared.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                isProcessing = false

                switch result {
                case .success(let text):
                    recognizedText = text
                    parsedData = BusinessCardParser.shared.parse(text: text)
                    showEditView = true

                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
