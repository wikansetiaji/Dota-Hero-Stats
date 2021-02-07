//
//  CoreDataDataSourceTests.swift
//  Dota Hero StatsTests
//
//  Created by Wikan Setiaji on 07/02/21.
//

import XCTest
@testable import Dota_Hero_Stats

class CoreDataDataSourceTests: XCTestCase {
    
    func testCreateAndFetch(){
        var result: [HeroModel]?
        let heroes = [HeroModel(imageUrl: "/apps/dota2/images/heroes/antimage_full.png?", name: "Anti-Mage", type: "Melee", agi: 24, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi"), HeroModel(imageUrl: "/apps/dota2/images/heroes/axe_full.png?", name: "Axe", type: "Melee", agi: 20, str: 25, int: 18, health: 200, maxAttack: 31, speed: 310, roles: ["Initiator", "Durable","Disabler", "Jungler"], primaryAttr: "str")].sorted
        { (a, b) -> Bool in
            a.name < b.name
        }
        
        CoreDataDataSource.createHeroes(heroModels: heroes)
        
        result = CoreDataDataSource.fetchHeroes().map({ (hero) -> HeroModel in
            HeroModel(coreDataModel: hero)
        }).sorted(by: { (a, b) -> Bool in
            a.name < b.name
        })
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, heroes)
        
        CoreDataDataSource.deleteAll()
    }
}
