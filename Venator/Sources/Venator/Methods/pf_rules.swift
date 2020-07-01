//
//  pf_rules.swift
//  Venator
//
//  Created by rderik  on 07/01/20.
//

import Foundation

func runPFRules(system_info: SystemInfo) {
    // get rules on /etc/pf.conf
    print("[+] Gathering /etc/pf.conf rules")
    if let pf_rules = getPFRules(system_info: system_info) {
        config.venator_data.pf_rules = pf_rules
    }
}

func getPFRules(system_info: SystemInfo) -> PFRules?{
    let path = "/etc/pf.conf"
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: path) {
        print("Error: /etc/pf.conf not found")
        return nil
    }
    do {
        let contents = try NSString(contentsOfFile: path,
                                    encoding: String.Encoding.utf8.rawValue)
        let pf_rules = PFRules(hostname: system_info.hostname,
                                  uuid: system_info.uuid,
                                  rules: contents as String)
        return pf_rules
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
    return nil
}

