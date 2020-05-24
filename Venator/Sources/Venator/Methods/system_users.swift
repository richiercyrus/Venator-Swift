//
//  system_users.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation
import Collaboration

func runSystemUsers(system_info: SystemInfo) {
    //get user info
    print("[+] Gathering user data")
    let users = getSystemUsers(system_info: system_info)
    // check to see if there is more than one user before assigning to struct
    if users.count > 0 {
        config.venator_data.users = users
        // collect usernames
        for i in users {
            config.usernames.append(i.username)
        }
    }
}

func getSystemUsers(system_info:SystemInfo) -> Array<User>{
    
    var systemUsers = Array<User>()
    
    
    let defaultAuthority = CSGetLocalIdentityAuthority().takeUnretainedValue()
    let identityClass = kCSIdentityClassUser
    let query = CSIdentityQueryCreate(nil, identityClass, defaultAuthority).takeRetainedValue()

    var error : Unmanaged<CFError>? = nil

    CSIdentityQueryExecute(query, 0, &error)

    let results = CSIdentityQueryCopyResults(query).takeRetainedValue()
    let resultsCount = CFArrayGetCount(results)
    var allUsersArray = [CBIdentity]()

    for idx in 0...resultsCount-1 {

        let identity    = unsafeBitCast(CFArrayGetValueAtIndex(results,idx),to: CSIdentity.self)
        let uuidString  = CFUUIDCreateString(nil, CSIdentityGetUUID(identity).takeUnretainedValue())

        if #available(OSX 10.11, *) {
            if let uuidNS = NSUUID(uuidString: uuidString! as String), let identityObject =  CBIdentity(uniqueIdentifier: uuidNS as UUID, authority: CBIdentityAuthority.default()){
                allUsersArray.append(identityObject)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    let group = CBGroupIdentity(posixGID: 80, authority: CBIdentityAuthority.default())
    
    for i in allUsersArray {
        let user = User(hostname: system_info.hostname,
                        uuid: system_info.uuid,
                        username: i.posixName,
                        isAdmin: i.isMember(ofGroup: group!))
        systemUsers.append(user)
    }
    
    return systemUsers
}
