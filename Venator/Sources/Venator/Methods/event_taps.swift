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
    print("[+] Gathering Event Taps data")
    let eventTaps = getEventTaps(systemInfo: system_info)
    if eventTaps.count > 0 {
        config.venator_data.event_taps = eventTaps
    }
}

func getEventTaps(systemInfo: SystemInfo) -> Array<EventTap> {
    var event_taps = Array<EventTap>()
    
    let taps = UnsafeMutablePointer<CGEventTapInformation>.allocate(capacity: 20)
    var eventTapCount:UInt32 = 20
    CGGetEventTapList(eventTapCount, taps, &eventTapCount)
    let tapBuffer = UnsafeBufferPointer(start: taps, count: Int(eventTapCount))
    if tapBuffer.count != 0 {
        for tap in tapBuffer {
            let eventTap = EventTap(hostname: systemInfo.hostname, uuid: systemInfo.uuid, id: tap.eventTapID, tappingProcessId: tap.tappingProcess, tappedProcessId: tap.processBeingTapped, enabled: tap.enabled)
            event_taps.append(eventTap)
        }
    }
    
    
    
    return event_taps
}
