//
//  CoreDataDataSource.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 07/02/21.
//

import Foundation
import CoreData
import UIKit

class CoreDataDataSource{
    static func fetchHeroes() -> [Hero]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Hero>(entityName: "Hero")
        
        do {
            let heroes = try managedContext.fetch(fetchRequest)
            return heroes
        }
        catch let error as NSError {
            print(error)
        }
        
        return []
    }
    
    static func createHeroes(heroModels: [HeroModel]){
        deleteAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for heroModel in heroModels{
            let _ = heroModel.toCoreDataModel(context: managedContext)
        }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print(error)
            return
        }
    }
    
    static func deleteAll(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let heroes = fetchHeroes()
        for a in heroes{
            managedContext.delete(a)
        }
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print(error)
        }
    }
}
