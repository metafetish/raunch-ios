//
//  Miiyoo.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-09.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A Miiyoo event.
struct MiiyooEvent {
    
    /// The time at which to fire the event, relative to the start of a track, in milliseconds.
    let time: RaunchTimeInterval
    
    /// The position/intensity of the event.
    let value: UInt8
}

// Display Miiyoo events as strings.
extension MiiyooEvent: CustomStringConvertible {
    
    var description: String {
        return "[time=\(time), value=\(value))"
    }
    
}

// A Miiyoo content track.
final class MiiyooTrack {
    
    /// The track's events.
    let events: [MiiyooEvent]
    
    /// Creates a Miiyoo content track.
    /// - Parameter events: The track's events.
    init(events: [MiiyooEvent]) {
        self.events = events
    }
    
    /// Creates a Miiyoo content track from data.
    /// - Parameter string: The track's event as string.
    convenience init(string: String) {
        
        // TODO: Do this better
        
        let events = string.components(separatedBy: ",").map { (string) -> MiiyooEvent in
            let array = string.components(separatedBy: ":")
            let time = RaunchTimeInterval(Double(array[0])! * 1000.0)
            let value = UInt8(array[1])!
            return MiiyooEvent(time: time, value: value)
        }
        
        self.init(events: events)
    }
    
}
