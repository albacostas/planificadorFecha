import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Build the managed object model programmatically so the app works without opening Xcode
        let model = NSManagedObjectModel()

        // CDEvent entity
        let eventEntity = NSEntityDescription()
        eventEntity.name = "CDEvent"
        eventEntity.managedObjectClassName = "NSManagedObject"

        func attr(_ name: String, type: NSAttributeType, optional: Bool = true) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = optional
            return a
        }

        var eventProps: [NSPropertyDescription] = []
        eventProps.append(attr("id", type: .UUIDAttributeType, optional: false))
        eventProps.append(attr("symbol", type: .stringAttributeType, optional: true))
        eventProps.append(attr("title", type: .stringAttributeType, optional: true))
        eventProps.append(attr("date", type: .dateAttributeType, optional: false))
        eventProps.append(attr("calendarID", type: .UUIDAttributeType, optional: true))
        eventProps.append(attr("subtype", type: .stringAttributeType, optional: true))
        eventProps.append(attr("repeatFrequency", type: .stringAttributeType, optional: true))
        eventProps.append(attr("repeatEndDate", type: .dateAttributeType, optional: true))
        // Binary Data for tasks and color (we'll encode as JSON/Data)
        eventProps.append(attr("tasksData", type: .binaryDataAttributeType, optional: true))
        eventProps.append(attr("colorData", type: .binaryDataAttributeType, optional: true))

        eventEntity.properties = eventProps

        // CDSubcalendar entity
        let subEntity = NSEntityDescription()
        subEntity.name = "CDSubcalendar"
        subEntity.managedObjectClassName = "NSManagedObject"

        var subProps: [NSPropertyDescription] = []
        subProps.append(attr("id", type: .UUIDAttributeType, optional: false))
        subProps.append(attr("title", type: .stringAttributeType, optional: false))
        subProps.append(attr("isVisible", type: .booleanAttributeType, optional: false))
        subProps.append(attr("colorData", type: .binaryDataAttributeType, optional: true))
        subEntity.properties = subProps

        model.entities = [eventEntity, subEntity]

        container = NSPersistentContainer(name: "Planificador", managedObjectModel: model)

        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        } else {
            // set default URL in Application Support
            let storeURL = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true).appendingPathComponent("Planificador.sqlite")
            if let url = storeURL {
                let desc = NSPersistentStoreDescription(url: url)
                container.persistentStoreDescriptions = [desc]
            }
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production handle error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}
