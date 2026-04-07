import SwiftUI
import CoreData

struct BusinessCardEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State var name: String
    @State var company: String
    @State var jobTitle: String
    @State var email: String
    @State var phone: String
    @State var address: String
    @State var website: String
    @State var notes: String

    let capturedImage: UIImage?
    let rawText: String?
    let existingCard: NSManagedObject?

    init(name: String = "", company: String = "", jobTitle: String = "", email: String = "", phone: String = "", address: String = "", website: String = "", notes: String = "", capturedImage: UIImage? = nil, rawText: String? = nil, existingCard: NSManagedObject? = nil) {
        _name = State(initialValue: name)
        _company = State(initialValue: company)
        _jobTitle = State(initialValue: jobTitle)
        _email = State(initialValue: email)
        _phone = State(initialValue: phone)
        _address = State(initialValue: address)
        _website = State(initialValue: website)
        _notes = State(initialValue: notes)
        self.capturedImage = capturedImage
        self.rawText = rawText
        self.existingCard = existingCard
    }

    var body: some View {
        NavigationView {
            Form {
                if let image = capturedImage {
                    Section(header: Text("Card Image")) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                } else if let imageData = existingCard?.value(forKey: "imageData") as? Data,
                          let uiImage = UIImage(data: imageData) {
                    Section(header: Text("Card Image")) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                }

                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Job Title", text: $jobTitle)
                }

                Section(header: Text("Company")) {
                    TextField("Company", text: $company)
                }

                Section(header: Text("Contact Information")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section(header: Text("Address")) {
                    TextField("Address", text: $address)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                if let raw = rawText {
                    Section(header: Text("Raw Text")) {
                        Text(raw)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBusinessCard()
                    }
                }
            }
        }
    }

    private func saveBusinessCard() {
        let card: NSManagedObject

        if let existing = existingCard {
            // Edit existing card
            card = existing
        } else {
            // Create new card
            card = NSEntityDescription.insertNewObject(forEntityName: "BusinessCard", into: viewContext)
            card.setValue(Date(), forKey: "createdAt")
        }

        card.setValue(name, forKey: "name")
        card.setValue(company, forKey: "company")
        card.setValue(jobTitle, forKey: "jobTitle")
        card.setValue(email, forKey: "email")
        card.setValue(phone, forKey: "phone")
        card.setValue(address, forKey: "address")
        card.setValue(website, forKey: "website")
        card.setValue(notes, forKey: "notes")

        if let raw = rawText {
            card.setValue(raw, forKey: "rawText")
        }

        if let image = capturedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            card.setValue(imageData, forKey: "imageData")
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            print("Error saving business card: \(nsError), \(nsError.userInfo)")
        }
    }
}
