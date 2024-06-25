//
//  BreweryService.swift
//  Brewspective
//
//  Created by Erik Kuipers on 29.04.24.
//

import Foundation
import Combine
import MapKit


class BreweryService {
    func fetchBreweries(query: String = "", page: Int = 1, completion: @escaping ([Brewery]?, Error?) -> Void) {
        let baseURL = "https://api.openbrewerydb.org/v1/breweries"
        let perPage = 200
        let searchPerPage = 25
        
        let urlString = query.isEmpty ? "\(baseURL)?per_page=\(perPage)&page=\(page)" :
        "\(baseURL)/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&per_page=\(searchPerPage)&page=\(page)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "No data received", code: 2, userInfo: nil))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([Brewery].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }


    
    func fetchAllBreweries(query: String = "", currentPage: Int = 1, allBreweries: [Brewery] = [], completion: @escaping ([Brewery]?, Error?) -> Void) {
        fetchBreweries(query: query, page: currentPage) { breweries, error in
            if let error = error {
                completion(nil, error)
            } else if let breweries = breweries, !breweries.isEmpty {
                self.fetchAllBreweries(query: query, currentPage: currentPage + 1, allBreweries: allBreweries + breweries, completion: completion)
            } else {
                completion(allBreweries, nil)
            }
        }
    }
}



struct BreweryServiceMap {
    func fetchBreweriesMap(completion: @escaping ([BreweryDetail]?, Error?) -> Void) {
        let url = URL(string: "https://api.openbrewerydb.org/v1/breweries")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "No data received", code: 1, userInfo: nil))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([BreweryDetail].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}

struct BreweryServiceType {
    func fetchBreweriesType(byType: String, page: Int = 1, completion: @escaping ([BreweryDetail]?, Error?) -> Void) {
        let urlString = "https://api.openbrewerydb.org/breweries?by_type=\(byType)&per_page=100&page=\(page)"
        print("Fetching data from URL: \(urlString)")  // Debug statement to check URL
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "No data received", code: 1, userInfo: nil))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([BreweryDetail].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}


struct BreweryServiceCountry {
    func fetchBreweriesCountry(byCountry country: String, page: Int = 1, completion: @escaping ([BreweryDetail]?, Error?) -> Void) {
        let urlString = "https://api.openbrewerydb.org/v1/breweries?by_country=\(country)&per_page=100&page=\(page)"
        print("Fetching data from URL: \(urlString)") 
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "No data received", code: 1, userInfo: nil))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([BreweryDetail].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}

