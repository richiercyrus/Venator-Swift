//
//  chrome_extensions.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

@available(OSX 10.11, *)
func runChromeExtensions(usernames: Array<String>, system_info: SystemInfo) {
    // get chrome extensions
    print("[+] Gathering Chrome extensions data")
    let chrome_extensions = getChromeExtensions(users: usernames,
                                                  system_info: system_info)
    if chrome_extensions.count > 0 {
        config.venator_data.chrome_extensions = chrome_extensions
    }
}

@available(OSX 10.11, *)
func getChromeExtensions(users: Array<String>, system_info: SystemInfo) -> Array<ChromeExtension> {
    var chrome_extensions = Array<ChromeExtension>()
    let fileManager = FileManager.default
    for user in users {
        do {
            let path = "/Users/\(user)/Library/Application Support/Google/Chrome/Default/Extensions/"
            let extensions = try fileManager.contentsOfDirectory(atPath:path)
            for ext in extensions {
                let full_ext = path+ext
                if let enumerator = fileManager.enumerator(atPath: full_ext) {
                    for file in enumerator {
                        if let ext_path = NSURL(fileURLWithPath: file as! String, relativeTo: NSURL(fileURLWithPath: full_ext, isDirectory: true) as URL).path {
                            if (ext_path.contains("manifest.json")) {
                                let data = try Data(contentsOf: URL(fileURLWithPath: ext_path), options: .mappedIfSafe)
                                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                                    if ((jsonResult["name"]!).contains("__MSG") == false) {
                                        let c_extension = ChromeExtension(hostname: system_info.hostname,
                                                                          uuid: system_info.uuid,
                                                                          user: user as String,
                                                                          extension_id: ext,
                                                                          extension_name: jsonResult["name"] as? String,
                                                                          extension_update_url: jsonResult["update_url"] as? String,
                                                                          extension_description: jsonResult["description"] as? String)
                                        chrome_extensions.append(c_extension)
                                    }
                                }
                
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
        catch {

        }
    }
    return chrome_extensions
}
