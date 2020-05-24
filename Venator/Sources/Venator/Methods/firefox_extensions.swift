//
//  firefox_extensions.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation

func runFireFoxExtensions(usernames: Array<String>, system_info: SystemInfo) {
    // get firefox extensions
    print("[+] Gathering Firefox extensions data")
    let firefox_extensions = getFirefoxExtensions(users: usernames,
                                                  system_info: system_info)
    if firefox_extensions.count > 0 {
        config.venator_data.firefox_extensions = firefox_extensions
    }
}

func getFirefoxExtensions(users: Array<String>, system_info: SystemInfo) -> Array<FireFoxExtension> {
    var firefox_extensions = Array<FireFoxExtension>()
    for user in users {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: "/Users/\(user)/Library/Application Support/Firefox/Profiles/hpctmktr.default-release/extensions.json"), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let addons = jsonResult["addons"] as? [Dictionary<String, AnyObject>] {
                for i in addons {
                    let locale = i["defaultLocale"] as? Dictionary<String, AnyObject>
                    var updateDate = i["updateDate"] // TODO figure out this NSFCNumber nonsense
                    if updateDate == nil {
                        updateDate = "" as String as AnyObject
                    }
                    var description = ""
                    if locale!["description"] != nil {
                         description = (locale!["description"]! as? String)!
                    }
                    var homepageURL = ""
                    if locale!["homepageURL"] != nil  {
                        homepageURL = (locale!["homepageURL"]! as? String)!
                    }
                    let f_extension = FireFoxExtension(hostname: system_info.hostname,
                                                       uuid: system_info.uuid,
                                                       user: user as String,
                                                       extension_id: i["id"]! as? String,
                                                       extension_update_url: i["updateURL"]! as? String,
                                                       extension_options_url: i["optionsURL"]! as? String,
                                                       extension_install_date: i["installDate"]! as? String,
                                                       extension_last_updated: nil, // TODO figure out this NSFCNumber nonsense
                                                       extension_source_uri: i["sourceURI"]! as? String,
                                                       extension_name: locale!["name"]! as? String,
                                                       extension_description: description,
                                                       extension_creator: locale!["creator"]! as? String,
                                                       extension_homepage_url: homepageURL)
                    firefox_extensions.append(f_extension)
                }
            }
        }
        catch {

        }
    }
    return firefox_extensions
}
