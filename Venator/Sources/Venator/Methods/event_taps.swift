//
//  event_taps.swift
//  Venator
//
//  Created by defaultuser on 5/10/20.
//

import Foundation
import CoreGraphics
import Quartz

func runEventTaps(system_info: SystemInfo) {
    // get firefox extensions
    print("[+] Gathering Event Taps data")
    let eventTaps = getEventTaps(systemInfo: system_info)
    if eventTaps.count > 0 {
        config.venator_data.event_taps = eventTaps
    }
}

func getEventTaps(systemInfo: SystemInfo) -> Array<EventTap> {
    var event_taps = Array<EventTap>()
    
    var taps: Array<CGEventTapInformation> = []
    var eventTapCount:UInt32 = 0
    CGGetEventTapList(eventTapCount, &taps, &eventTapCount)
    if taps.count != 0 {
        for tap in taps {
            let eventTap = EventTap(hostname: systemInfo.hostname, uuid: systemInfo.uuid, id: tap.eventTapID, tappingProcessId: tap.tappingProcess, tappedProcessId: tap.processBeingTapped, enabled: tap.enabled)
            event_taps.append(eventTap)
        }
    }
    
    
    
    return event_taps
}
