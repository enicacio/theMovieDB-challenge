//
//  CoreDataStack.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MovieDB")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
