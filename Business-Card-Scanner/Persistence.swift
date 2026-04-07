import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<3 {
            let newCard = NSEntityDescription.insertNewObject(forEntityName: "BusinessCard", into: viewContext)
            newCard.setValue("John Doe \(i+1)", forKey: "name")
            newCard.setValue("Tech Company Inc.", forKey: "company")
            newCard.setValue("Software Engineer", forKey: "jobTitle")
            newCard.setValue("john.doe\(i+1)@example.com", forKey: "email")
            newCard.setValue("+1 (555) 123-456\(i)", forKey: "phone")
            newCard.setValue("123 Tech Street, Silicon Valley, CA", forKey: "address")
            newCard.setValue("www.techcompany.com", forKey: "website")
            newCard.setValue(Date(), forKey: "createdAt")
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Business_Card_Scanner")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
