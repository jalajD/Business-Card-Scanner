import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "BusinessCard", in: PersistenceController.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)],
        animation: .default)
    private var businessCards: FetchedResults<NSManagedObject>

    @State private var showScanView = false
    @State private var searchText = ""

    var filteredCards: [NSManagedObject] {
        if searchText.isEmpty {
            return Array(businessCards)
        } else {
            return businessCards.filter { card in
                let name = (card.value(forKey: "name") as? String) ?? ""
                let company = (card.value(forKey: "company") as? String) ?? ""
                let email = (card.value(forKey: "email") as? String) ?? ""
                let phone = (card.value(forKey: "phone") as? String) ?? ""

                return name.localizedCaseInsensitiveContains(searchText) ||
                       company.localizedCaseInsensitiveContains(searchText) ||
                       email.localizedCaseInsensitiveContains(searchText) ||
                       phone.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                if businessCards.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)

                        Text("No Business Cards")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Tap the + button to scan your first business card")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(filteredCards, id: \.self) { card in
                            NavigationLink {
                                BusinessCardDetailView(card: card)
                            } label: {
                                BusinessCardRow(card: card)
                            }
                        }
                        .onDelete(perform: deleteCards)
                    }
                    .searchable(text: $searchText, prompt: "Search by name, company, email, or phone")
                }
            }
            .navigationTitle("Business Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !businessCards.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showScanView = true
                    }) {
                        Label("Scan Card", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showScanView) {
                ScanBusinessCardView()
            }
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredCards[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting cards: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct BusinessCardRow: View {
    @ObservedObject var card: NSManagedObject

    var body: some View {
        HStack(spacing: 12) {
            if let imageData = card.value(forKey: "imageData") as? Data,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "person.crop.rectangle")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let name = card.value(forKey: "name") as? String, !name.isEmpty {
                    Text(name)
                        .font(.headline)
                } else {
                    Text("Unknown")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                if let company = card.value(forKey: "company") as? String, !company.isEmpty {
                    Text(company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let email = card.value(forKey: "email") as? String, !email.isEmpty {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
