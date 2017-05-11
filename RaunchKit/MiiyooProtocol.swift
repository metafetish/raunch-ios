//
//  Miiyoo.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-09.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A Miiyoo event.
public struct MiiyooEvent {
    
    /// The time at which to fire the event, relative to the start of a track, in milliseconds.
    public let time: RaunchTimeInterval
    
    /// The position/intensity of the event.
    public let value: UInt8
}

// Display Miiyoo events as strings.
extension MiiyooEvent: CustomStringConvertible {
    
    public var description: String {
        return "[time=\(time.description), value=\(value))"
    }
    
}

// A Miiyoo content track.
public final class MiiyooTrack {
    
    /// The track's events.
    public let events: [MiiyooEvent]
    
    /// Creates a Miiyoo content track.
    /// - Parameter events: The track's events.
    public init(events: [MiiyooEvent]) {
        self.events = events
    }
    
    /// Creates a Miiyoo content track from data.
    /// - Parameter string: The track's event as string.
    public convenience init(string: String) {
        
        // TODO: Do this better
        
        let events = string.components(separatedBy: ",").map { (string) -> MiiyooEvent in
            let array = string.components(separatedBy: ":")
            let time = RaunchTimeInterval(milliseconds: Int64(Double(array[0])! * 1000.0))
            let value = UInt8(array[1])!
            return MiiyooEvent(time: time, value: value)
        }
        
        self.init(events: events)
    }
    
}
