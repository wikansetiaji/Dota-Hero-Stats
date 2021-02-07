//
//  HeroModel.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import Foundation
import CoreData

struct HeroModel: Codable, Equatable{
    let imageUrl: String
    let name: String
    let type: String
    let agi: Int
    let str: Int
    let int: Int
    let health: Int
    let maxAttack: Int
    let speed: Int
    let roles: [String]
    let primaryAttr: String
    
    init(imageUrl: String, name: String, type: String, agi: Int, str: Int, int: Int, health: Int , maxAttack: Int, speed: Int, roles: [String], primaryAttr: String) {
        self.imageUrl = imageUrl
        self.name = name
        self.type = type
        self.agi = agi
        self.str = str
        self.int = int
        self.health = health
        self.maxAttack = maxAttack
        self.speed = speed
        self.roles = roles
        self.primaryAttr = primaryAttr
    }
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "img"
        case name = "localized_name"
        case type = "attack_type"
        case primaryAttr = "primary_attr"
        case agi = "base_agi"
        case str = "base_str"
        case int = "base_int"
        case health = "base_health"
        case maxAttack = "base_attack_max"
        case speed = "move_speed"
        case roles = "roles"
    }
    
    func toCoreDataModel(context: NSManagedObjectContext) -> Hero{
        let hero = Hero(context: context)
        hero.imageUrl = imageUrl
        hero.name = name
        hero.type = type
        hero.agi = Int64(agi)
        hero.str = Int64(str)
        hero.int = Int64(int)
        hero.health = Int64(health)
        hero.maxAttack = Int64(maxAttack)
        hero.speed = Int64(speed)
        hero.roles = roles
        hero.primaryAttr = primaryAttr
        return hero
    }
    
    init(coreDataModel: Hero) {
        imageUrl = coreDataModel.imageUrl ?? ""
        name = coreDataModel.name ?? ""
        type = coreDataModel.type ?? ""
        agi = Int(coreDataModel.agi)
        str = Int(coreDataModel.str)
        int = Int(coreDataModel.int)
        health = Int(coreDataModel.health)
        maxAttack = Int(coreDataModel.maxAttack)
        speed = Int(coreDataModel.speed)
        roles = coreDataModel.roles ?? []
        primaryAttr = coreDataModel.primaryAttr ?? ""
    }
}

@objc(NSStringArrayTransformer)
class NSStringArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return super.allowedTopLevelClasses + [NSArray.self]
    }
}
