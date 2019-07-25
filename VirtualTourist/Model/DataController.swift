//
//  DataController.swift
//  VirtualTourist
//
//  Created by Shrooq Saleh on 06.07.19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData
class DataController{
    static let shared = DataController()
    let persostentContainer = NSPersistentContainer(name: "Model")
    
    var viewContext: NSManagedObjectContext{
        return persostentContainer.viewContext
    }
    
    func load(){
        persostentContainer.loadPersistentStores{(storeDescription, err)in
            guard err == nil else{
                fatalError(err!.localizedDescription)
            }
        }
    }
}
