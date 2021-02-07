//
//  HeroViewModelTests.swift
//  Dota Hero StatsTests
//
//  Created by Wikan Setiaji on 07/02/21.
//

import XCTest
@testable import Dota_Hero_Stats

class HeroViewModelTests: XCTestCase {
    var apiRequest: APIDataSource = APIDataSource.shared
    
    func testFetchHeroes() {
        var displayedHeroesChangedCalled = false
        var loadingChangedCalled = false
        let exp = expectation(description: "hero")
        let configuration = URLSessionConfiguration.default
        
        //Hero raw data
        let data = "[{\"id\": 1,\"name\": \"npc_dota_hero_antimage\",\"localized_name\": \"Anti-Mage\",\"primary_attr\": \"agi\",\"attack_type\": \"Melee\",\"roles\": [    \"Carry\",    \"Escape\",    \"Nuker\"],\"img\": \"/apps/dota2/images/heroes/antimage_full.png?\",\"icon\": \"/apps/dota2/images/heroes/antimage_icon.png\",\"base_health\": 200,\"base_health_regen\": 0.25,\"base_mana\": 75,\"base_mana_regen\": 0,\"base_armor\": -1,\"base_mr\": 25,\"base_attack_min\": 29,\"base_attack_max\": 33,\"base_str\": 23,\"base_agi\": 24,\"base_int\": 12,\"str_gain\": 1.3,\"agi_gain\": 2.8,\"int_gain\": 1.8,\"attack_range\": 150,\"projectile_speed\": 0,\"attack_rate\": 1.4,\"move_speed\": 310,\"turn_rate\": 0.5,\"cm_enabled\": true,\"legs\": 2,\"hero_id\": 1,\"turbo_picks\": 86788,\"turbo_wins\": 44597,\"pro_win\": 48,\"pro_pick\": 85,\"pro_ban\": 257,\"1_pick\": 21868,\"1_win\": 10955,\"2_pick\": 47993,\"2_win\": 24275,\"3_pick\": 68428,\"3_win\": 34636,\"4_pick\": 68942,\"4_win\": 34281,\"5_pick\": 45909,\"5_win\": 22895,\"6_pick\": 20818,\"6_win\": 10171,\"7_pick\": 8495,\"7_win\": 4119,\"8_pick\": 2136,\"8_win\": 980,\"null_pick\": 2396564,\"null_win\": 0}]".data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == URL(string: "https://api.opendota.com/api/herostats")! else {
                throw NSError()
            }
            
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        apiRequest.session = urlSession
        
        let viewModel = HeroViewModel()
        viewModel.fetchHeroes(isRefresh: false)
        
        viewModel.loadingStateChanged = { (_) in
            loadingChangedCalled = true
        }
        
        viewModel.displayedHeroesChanged = {(_) in
            displayedHeroesChangedCalled = true
            exp.fulfill()
            CoreDataDataSource.deleteAll()
        }
        
        let antimage = HeroModel(imageUrl: "/apps/dota2/images/heroes/antimage_full.png?", name: "Anti-Mage", type: "Melee", agi: 24, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertTrue(displayedHeroesChangedCalled)
            XCTAssertEqual(viewModel.heroes, [antimage])
            XCTAssertTrue(loadingChangedCalled)
        }
    }
    
    func testErrorChangedCalled() {
        var errorChanged = false
        var err: APIDataSource.Error?
        let exp = expectation(description: "fail")
        let configuration = URLSessionConfiguration.default
        
        let data = Data()
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "mock")!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        apiRequest.session = urlSession
        
        let viewModel = HeroViewModel()
        viewModel.fetchHeroes(isRefresh: false)
        
        viewModel.errorChanged = {(error) in
            exp.fulfill()
            errorChanged = true
            err = error
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertTrue(errorChanged)
            XCTAssertEqual(err, .noInternet)
        }
    }
    
    func testFilterDisplayedHeroes(){
        let viewModel = HeroViewModel()
        var displayedHeroes: [HeroModel]?
        
        let testHeroes = [HeroModel(imageUrl: "/apps/dota2/images/heroes/antimage_full.png?", name: "Anti-Mage", type: "Melee", agi: 24, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi"), HeroModel(imageUrl: "/apps/dota2/images/heroes/axe_full.png?", name: "Axe", type: "Melee", agi: 20, str: 25, int: 18, health: 200, maxAttack: 31, speed: 310, roles: ["Initiator", "Durable","Disabler", "Jungler"], primaryAttr: "str")].sorted
        { (a, b) -> Bool in
            a.name < b.name
        }
        viewModel.heroes = testHeroes
                
        viewModel.displayedHeroesChanged = {(heroes) in
            displayedHeroes = heroes
        }
        
        viewModel.filterHeroes(role: ["Carry"], query: "")
        
        XCTAssertEqual(displayedHeroes, [HeroModel(imageUrl: "/apps/dota2/images/heroes/antimage_full.png?", name: "Anti-Mage", type: "Melee", agi: 24, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")])
        
        viewModel.filterHeroes(role: [], query: "Ax")
        
        XCTAssertEqual(displayedHeroes, [HeroModel(imageUrl: "/apps/dota2/images/heroes/axe_full.png?", name: "Axe", type: "Melee", agi: 20, str: 25, int: 18, health: 200, maxAttack: 31, speed: 310, roles: ["Initiator", "Durable","Disabler", "Jungler"], primaryAttr: "str")])
    }
    
    func testSimiliarHeroes(){
        let viewModel = HeroViewModel()
        let agiHero1 = HeroModel(imageUrl: "url", name: "agiHero1", type: "Melee", agi: 50, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        let agiHero2 = HeroModel(imageUrl: "url", name: "agiHero2", type: "Melee", agi: 45, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        let agiHero3 = HeroModel(imageUrl: "url", name: "agiHero3", type: "Melee", agi: 40, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        let agiHero4 = HeroModel(imageUrl: "url", name: "agiHero4", type: "Melee", agi: 35, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        
        viewModel.heroes = [agiHero1, agiHero2, agiHero3, agiHero4]
        
        let similiarHeroes = viewModel.getSimiliarHeroes(hero: agiHero3)
        
        XCTAssertEqual(similiarHeroes, [agiHero1, agiHero2, agiHero4])
    }

}
