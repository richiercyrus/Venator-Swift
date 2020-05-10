//
//  bash_history.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

func getBashHistory(users: Array<String>, system_info: SystemInfo) -> Array<BashHistory>{
    var bash_history = Array<BashHistory>()
    for i in users {
        do {
            let contents = try NSString(contentsOfFile: "/Users/\(i)/.bash_history",
                                        encoding: String.Encoding.utf8.rawValue)
            let history = BashHistory(hostname: system_info.hostname,
                                      uuid: system_info.uuid,
                                      user: i,
                                      bash_commands: contents as String)
            bash_history.append(history)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    return bash_history
}
