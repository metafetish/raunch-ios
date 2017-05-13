//
//  Commands.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A command to send to the toy.
public struct RaunchCommand {
    
    /// The desired position of the toy.
    public let position: Int
    
    // The speed at which the toy should move.
    public let speed: Int
    
    /// Creates a timed command.
    public init(position: Int, speed: Int) throws {
        self.position = try validate(position: position)
        self.speed = try validate(speed: speed)
    }
    
}

// Display Raunch commands as strings.
extension RaunchCommand: CustomStringConvertible {
    
    public var description: String {
        return "[position=\(position), speed=\(speed))"
    }
    
}

/// An event (a command to send the toy at a a scheduled time).
public struct RaunchEvent {
    
    /// The time at which to fire the command, relative to the start of a track, in milliseconds.
    public let time: RaunchTimeInterval
    
    /// The command to send.
    public let command: RaunchCommand
    
    /// Creates a timed command.
    public init(time: RaunchTimeInterval, position: Int, speed: Int) throws {
        self.time = time
        self.command = try RaunchCommand(position: position, speed: speed)
    }
    
}

// Display Raunch events as strings.
extension RaunchEvent: CustomStringConvertible {
    
    public var description: String {
        return "[time=\(time.description), position=\(command.position), speed=\(command.speed))"
    }
    
}

/// A Raunch content track.
public final class RaunchTrack {
    
    /// The track's commands.
    public let events: [RaunchEvent]
    
    /// Creates a Raunch content track.
    /// - Parameter events: The track's events.
    public init(events: [RaunchEvent]) {
        self.events = events
    }
    
}

/// Validates a position.
func validate(position: Int) throws -> Int {
    guard position >= 0 && position <= 99 else {
        throw RaunchError.invalidPositionValue
    }
    return position
}

/// Validates a speed.
func validate(speed: Int) throws -> Int {
    guard speed >= 20 && speed <= 99 else {
        throw RaunchError.invalidSpeedValue
    }
    return speed
}
