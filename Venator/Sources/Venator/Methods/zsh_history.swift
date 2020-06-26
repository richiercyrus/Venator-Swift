

import Foundation

func runZshHistory(usernames: Array<String>, system_info: SystemInfo) {
    // get bash history
    print("[+] Gathering zsh history data")
    let zsh_history = getZshHistory(users: usernames,
                                      system_info: system_info)
    if zsh_history.count > 0 {
        config.venator_data.zsh_history = zsh_history
    }
}

func getZshHistory(users: Array<String>, system_info: SystemInfo) -> Array<ZshHistory>{
    var zsh_history = Array<ZshHistory>()
    for i in users {
        let path = "/Users/\(i)/.zsh_history"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            continue
        }
        do {
            let contents = try NSString(contentsOfFile: path,
                                        encoding: String.Encoding.utf8.rawValue)
            let history = ZshHistory(hostname: system_info.hostname,
                                      uuid: system_info.uuid,
                                      user: i,
                                      zsh_commands: contents as String)
            zsh_history.append(history)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    return zsh_history
}
