//
//  main.swift
//  Venator2
//
//  Created by defaultuser on 5/8/20.
//  Copyright © 2020 defaultuser. All rights reserved.
//

import Foundation
import ArgumentParser

struct Venator: ParsableCommand {
    @Option(name: .shortAndLong, help: "File path to output file")
    var out: String?
    
    @Option(name: .shortAndLong, help: "VirusTotal API key to use for hash lookups")
    var virustotal: String?
    
    @Option(name: .shortAndLong, help: "AWS bucket to use for S3 upload")
    var bucket: String?
    
    @Option(name: .shortAndLong, help: "AWS id to use for S3 upload")
    var id: String?
    
    @Option(name: .shortAndLong, help: "AWS secret to use for S3 upload")
    var secret: String?
    
    @Option(name: .shortAndLong, help: "AWS region to use for S3 upload")
    var region: String?
    
    @Option(name: .shortAndLong, help: "Select which modules to run with a comma seperated list")
    var modules: String?

    func run() throws {
        // print banner
        printBanner()
        
        let vt: Bool
        if virustotal != nil {
            vt = true
        }
        else {
            vt = false
        }
        
        let upload: Bool
        if (bucket != nil) && (id != nil) && (secret != nil) && (region != nil) {
            upload = true
        }
        else {
            upload = false
        }
        
        var list = Array<String>()
        if modules != nil {
            let split = modules!.split(separator: ",")
            for i in split {
                list.append(String(i))
            }
        }
        
        config = VenatorConfig(venator_data: VenatorData(),
                                   modules: list,
                                   usernames: Array<String>(),
                                   attempts: 0,
                                   checkVT: vt,
                                   upload: upload,
                                   vt_key: virustotal,
                                   filename: out,
                                   aws_bucket: bucket,
                                   aws_id: id,
                                   aws_secret: secret,
                                   aws_region: region)
        dispatchVenator()
    }
}

// declare var
var config: VenatorConfig

// check for root privs
checkRoot()

// execute Veantor
Venator.main()
