//
//  HeroViewModel.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import Foundation

class HeroViewModel{
    var loadingStateChanged: ((Bool) -> Void)?
    var displayedHeroesChanged: (([HeroModel]) -> Void)?
    var errorChanged: ((APIDataSource.Error?) -> Void)?
    
    var heroes: [HeroModel] = []
    var displayedHeroes: [HeroModel] = []{
        didSet{
            displayedHeroesChanged?(displayedHeroes)
        }
    }
    var isLoading = false{
        didSet{
            loadingStateChanged?(isLoading)
        }
    }
    
    var error: APIDataSource.Error?{
        didSet{
            errorChanged?(error)
        }
    }
    
    func fetchHeroes(isRefresh: Bool){
        isLoading = true
        
        // Getting the CoreData cache
        if !isRefresh{
            let coreDataHeroes = CoreDataDataSource.fetchHeroes().map { (hero) -> HeroModel in
                HeroModel(coreDataModel: hero)
            }
            if coreDataHeroes.count != 0{
                heroes = coreDataHeroes.sorted(by: { (a, b) -> Bool in
                    a.name < b.name
                })
                self.displayedHeroes = self.heroes
                isLoading = false
            }
        }
        
        APIDataSource.shared.fetchHeroes { (heroes) in
            self.isLoading = false
            self.heroes = heroes.sorted(by: { (a, b) -> Bool in
                a.name < b.name
            })
            self.displayedHeroes = self.heroes
            
            // Updating the CoreData cache
            DispatchQueue.main.async {
                CoreDataDataSource.createHeroes(heroModels: self.heroes)
            }
        } errorFetch: { (err) in
            self.isLoading = false
            self.error = err
        }
    }
    
    func filterHeroes(role: [String], query: String){
        displayedHeroes = []
        displayedHeroes = heroes.filter { (hero) -> Bool in
            let heroRoleSet = Set(hero.roles)
            let roleSet = Set(role)
            var result =  roleSet.isSubset(of: heroRoleSet)
            if query != ""{
                result = result && hero.name.lowercased().contains(query.lowercased())
            }
            
            return result
        }
    }
    
    func getSimiliarHeroes(hero: HeroModel) -> [HeroModel]{
        var sameAttr = heroes.filter { (a) -> Bool in
            a.type == hero.type
        }
        sameAttr.sort { (a, b) -> Bool in
            if hero.primaryAttr == "str"{
                return a.str > b.str
            }
            else if hero.primaryAttr == "int"{
                return a.int > b.int
            }
            else{
                return a.agi > b.agi
            }
        }
        
        var result: [HeroModel] = []
        
        var count = 0
        
        for a in sameAttr{
            if hero.name != a.name{
                result.append(a)
                count += 1
            }
            if count == 3{
                break
            }
        }
        
        return result
    }
}
