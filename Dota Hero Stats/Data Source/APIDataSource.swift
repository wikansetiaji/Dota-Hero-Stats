//
//  APIRequest.swift
//  Dota Hero Stats
//
//  Created by Wikan Setiaji on 04/02/21.
//

import Foundation

class APIDataSource{
    static let shared = APIDataSource()
    
    enum Error {
        case zeroItem
        case noInternet
    }
    
    var session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.timeoutIntervalForRequest = 5
        
        session = URLSession.init(configuration: config)
    }
    
    func fetchHeroes(successFetch: @escaping ([HeroModel]) -> Void, errorFetch: @escaping (Error) -> Void) {
        let url = URL(string: "https://api.opendota.com/api/herostats")!
        
        session.dataTask(with: url).cancel()
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                errorFetch(Error.noInternet)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                errorFetch(Error.noInternet)
                return
            }
            
            if let data = data{
                let result = try! JSONDecoder().decode([HeroModel].self, from: data)
                if (result.count == 0){
                    errorFetch(Error.zeroItem)
                    return
                }
                successFetch(result)
            }
        })
        
        task.resume()
    }
}
