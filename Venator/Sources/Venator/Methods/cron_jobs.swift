//
//  cron_jobs.swift
//  Venator
//
//  Created by defaultuser on 5/9/20.
//

import Foundation

//get all cron jobs - "crontab","-u",user,"-l"
func getCronJobs(users: Array<String>, system_info: SystemInfo) -> Array<CronJob> {
    var cron_jobs = Array<CronJob>()
    // Set the task parameters
    for i in users {
        let task = Process()
        task.launchPath = "/usr/bin/crontab"
        task.arguments = ["-u", i, "-l"]
 
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardError = pipe
        // Launch the task
        task.launch()
        task.waitUntilExit()
 
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8) ?? ""
        
        let cron_job = CronJob(hostname: system_info.hostname,
                               uuid: system_info.uuid,
                               user: i,
                               crontab: output)
        cron_jobs.append(cron_job)
    }
    return cron_jobs
}
