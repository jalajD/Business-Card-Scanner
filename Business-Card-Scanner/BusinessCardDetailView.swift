import SwiftUI
import CoreData

struct BusinessCardDetailView: View {
    @ObservedObject var card: NSManagedObject
    @State private var showEditView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageData = card.value(forKey: "imageData") as? Data,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 16) {
                    if let name = card.value(forKey: "name") as? String, !name.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .font(.title)
                                .fontWeight(.bold)

                            if let jobTitle = card.value(forKey: "jobTitle") as? String, !jobTitle.isEmpty {
                                Text(jobTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let company = card.value(forKey: "company") as? String, !company.isEmpty {
                                Text(company)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)
                    }

                    if let email = card.value(forKey: "email") as? String, !email.isEmpty {
                        ContactRow(icon: "envelope.fill", label: "Email", value: email, color: .red)
                    }

                    if let phone = card.value(forKey: "phone") as? String, !phone.isEmpty {
                        ContactRow(icon: "phone.fill", label: "Phone", value: phone, color: .green)
                    }

                    if let website = card.value(forKey: "website") as? String, !website.isEmpty {
                        ContactRow(icon: "globe", label: "Website", value: website, color: .blue)
                    }

                    if let address = card.value(forKey: "address") as? String, !address.isEmpty {
                        ContactRow(icon: "map.fill", label: "Address", value: address, color: .orange)
                    }

                    if let notes = card.value(forKey: "notes") as? String, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.headline)
                                .foregroundColor(.purple)
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    if let createdAt = card.value(forKey: "createdAt") as? Date {
                        Text("Added on \(createdAt, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Business Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditView = true
                }
            }
        }
        .sheet(isPresented: $showEditView) {
            BusinessCardEditView(
                name: (card.value(forKey: "name") as? String) ?? "",
                company: (card.value(forKey: "company") as? String) ?? "",
                jobTitle: (card.value(forKey: "jobTitle") as? String) ?? "",
                email: (card.value(forKey: "email") as? String) ?? "",
                phone: (card.value(forKey: "phone") as? String) ?? "",
                address: (card.value(forKey: "address") as? String) ?? "",
                website: (card.value(forKey: "website") as? String) ?? "",
                notes: (card.value(forKey: "notes") as? String) ?? "",
                existingCard: card
            )
        }
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.headline)
                .foregroundColor(color)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
