//
//  Dota_Hero_StatsTests.swift
//  Dota Hero StatsTests
//
//  Created by Wikan Setiaji on 07/02/21.
//

import XCTest
@testable import Dota_Hero_Stats

class APIDataSourceTests: XCTestCase {
    var apiRequest: APIDataSource = APIDataSource.shared

    func testGetHeroesSuccess() {
        var heroes: [HeroModel]?
        let exp = expectation(description: "expectation")
        let configuration = URLSessionConfiguration.default
        
        //Hero raw data
        let data = "[{\"id\": 1,\"name\": \"npc_dota_hero_antimage\",\"localized_name\": \"Anti-Mage\",\"primary_attr\": \"agi\",\"attack_type\": \"Melee\",\"roles\": [    \"Carry\",    \"Escape\",    \"Nuker\"],\"img\": \"/apps/dota2/images/heroes/antimage_full.png?\",\"icon\": \"/apps/dota2/images/heroes/antimage_icon.png\",\"base_health\": 200,\"base_health_regen\": 0.25,\"base_mana\": 75,\"base_mana_regen\": 0,\"base_armor\": -1,\"base_mr\": 25,\"base_attack_min\": 29,\"base_attack_max\": 33,\"base_str\": 23,\"base_agi\": 24,\"base_int\": 12,\"str_gain\": 1.3,\"agi_gain\": 2.8,\"int_gain\": 1.8,\"attack_range\": 150,\"projectile_speed\": 0,\"attack_rate\": 1.4,\"move_speed\": 310,\"turn_rate\": 0.5,\"cm_enabled\": true,\"legs\": 2,\"hero_id\": 1,\"turbo_picks\": 86788,\"turbo_wins\": 44597,\"pro_win\": 48,\"pro_pick\": 85,\"pro_ban\": 257,\"1_pick\": 21868,\"1_win\": 10955,\"2_pick\": 47993,\"2_win\": 24275,\"3_pick\": 68428,\"3_win\": 34636,\"4_pick\": 68942,\"4_win\": 34281,\"5_pick\": 45909,\"5_win\": 22895,\"6_pick\": 20818,\"6_win\": 10171,\"7_pick\": 8495,\"7_win\": 4119,\"8_pick\": 2136,\"8_win\": 980,\"null_pick\": 2396564,\"null_win\": 0}]".data(using: .utf8)
        
        //Initiate mock url
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
        
        apiRequest.fetchHeroes { (result) in
            heroes = result
            exp.fulfill()
        } errorFetch: { (error) in}
        
        let antimage = HeroModel(imageUrl: "/apps/dota2/images/heroes/antimage_full.png?", name: "Anti-Mage", type: "Melee", agi: 24, str: 23, int: 12, health: 200, maxAttack: 33, speed: 310, roles: ["Carry","Escape","Nuker"], primaryAttr: "agi")
        
        waitForExpectations(timeout: 1) { (error) in
            // Check if heroes are fetched
            XCTAssertNotNil(heroes)
            // Check if the fetched hero is right
            XCTAssertEqual(heroes?.first, antimage)
        }
    }
    
    func testGetHeroesError() {
        var err: APIDataSource.Error?
        let errorExpectation = expectation(description: "error")
        let configuration = URLSessionConfiguration.default
        
        //Return the false data
        let data = Data()
        
        //Initiate mock url
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "https://api.opendota.com/api/herostats")!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        apiRequest.session = urlSession
        
        apiRequest.fetchHeroes { (heroes) in
        } errorFetch: { (error) in
            err = error
            errorExpectation.fulfill()
        }

        
        waitForExpectations(timeout: 1) { (error) in
            //Check if get error
            XCTAssertNotNil(err)
            //Check if error is right
            XCTAssertEqual(err, .noInternet)
        }
    }

}
