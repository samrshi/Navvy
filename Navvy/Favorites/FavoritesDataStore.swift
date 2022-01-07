//
//  FavoritesDataStore.swift
//  Navvy
//
//  Created by Samuel Shi on 1/6/22.
//

import CoreData
import Foundation
import MapKit

class FavoritesDataStore {
    static let shared = FavoritesDataStore()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Navvy")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Cannot load Core Data model: \(error.debugDescription)")
            }
        }
    }
    
    func getAll() -> [Destination] {
        let request = FavoriteDestinationEntity.fetchRequest()
        
        let sort = NSSortDescriptor(key: "dateCreated", ascending: false)
        request.sortDescriptors = [sort]
        
        let results = try? container.viewContext.fetch(request)
        let unwrappedResults = results ?? []
        
        return unwrappedResults
            .map(FavoritesDataStore.entityToDestination)
    }
    
    func save(destination: Destination) {
        let entity = FavoriteDestinationEntity(context: container.viewContext)
        
        entity.id = destination.id
        entity.dateCreated = Date()
        entity.urlString = destination.url?.absoluteString
        entity.phoneNumber = destination.phoneNumber
        entity.name = destination.name
        entity.category = destination.category?.rawValue
        entity.address = destination.address
        entity.latitude = destination.coordinates.latitude
        entity.longitude = destination.coordinates.longitude
        
        let context = container.viewContext
        try? context.save()
    }
    
    func remove(destination: Destination) {
        guard let entity = try? getEntityById(destination.id) else { return }
            
        let context = container.viewContext
        context.delete(entity)
            
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
    
    private func getEntityById(_ id: UUID) throws -> FavoriteDestinationEntity? {
        let request = FavoriteDestinationEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        let context = container.viewContext
        return try context.fetch(request).first
    }
    
    private static func entityToDestination(entity: FavoriteDestinationEntity) -> Destination {
        var category: MKPointOfInterestCategory?
        if let categoryRawValue = entity.category { category = MKPointOfInterestCategory(rawValue: categoryRawValue) }
        
        var url: URL?
        if let urlString = entity.urlString { url = URL(string: urlString) }
        
        let coordinates = CLLocationCoordinate2D(latitude: entity.latitude, longitude: entity.longitude)
        
        return Destination(
            id: entity.id!,
            name: entity.name ?? "Unknown Destination",
            category: category,
            coordinates: coordinates,
            url: url,
            address: entity.address,
            phoneNumber: entity.phoneNumber)
    }
}
