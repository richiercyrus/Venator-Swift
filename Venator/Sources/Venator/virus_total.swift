//
//  virus_total.swift
//  Venator
//
//  Created by defaultuser on 5/11/20.
//

import Foundation

func getVTResult(hash: String) -> String {
    var result = ""
    while result == "" {
        // sleep for 60 seconds after 4 attempts to keep under the api quota
        if attempts == 4 {
            sleep(60)
        }
        do {
            let data = try get(key: apikey, hash: hash)
            if data["response_code"] as! Int? == 0 {
                result = "This file has no VirusTotal entry"
            }
            else {
                if data["response_code"] as! Int? == 1 {
                    result = "\(String(describing: data["positives"]))/\(String(describing: data["total"] as! Int?))"
                }
                else {
                    result = "This file is OK"
                }
            }
            attempts += 1
        }
        catch {
            attempts += 1
        }
    }
    return result
}

// Define group to send results through DispathQueue
let group = DispatchGroup()

// Generic GET function
func get(key: String, hash: String) throws -> [String: Any] {
    group.enter()
    var results = [String: Any]()
    var getURLComponents = URLComponents()
    getURLComponents.scheme = "https"
    getURLComponents.host = "www.virustotal.com"
    getURLComponents.path = "/vtapi/v2/file/report"
    getURLComponents.port = 443
    let items = [URLQueryItem(name: "apikey", value: key), URLQueryItem(name: "resource", value: hash)]
    getURLComponents.queryItems = items
    let getURL = getURLComponents.url!
    var request = URLRequest(url: getURL)
    request.httpMethod = "GET"
    request.setValue("Venator", forHTTPHeaderField: "User-Agent")
    let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, response, error in
        if error != nil {
            print("error")
        } else if
            let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
                let raw = String(data: data, encoding: .utf8)!
                results = convertToDictionary(text: raw)!
        }
    group.leave()
    }
    task.resume()
    group.wait()
    return results
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
