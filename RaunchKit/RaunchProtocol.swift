//
//  Commands.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A command to send to the toy.
struct RaunchCommand {
    
    /// The time at which to fire the command, relative to the start of a track, in milliseconds.
    let time: RaunchTimeInterval
    
    /// The desired position of the toy.
    let position: Int
    
    // The speed at which the toy should move.
    let speed: Int
    
    /// Creates a timed command.
    /// - Parameter time: The time at which to fire the command.
    /// - Parameter position: The desired position of the toy. Valid values are 0-99.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 20-99.
    /// - Throws: `RaunchError.invalidPositionValue` if the position value is invalid.
    ///           `RaunchError.invalidSpeedValue` if the speed value is invalid.
    init(time: RaunchTimeInterval, position: Int, speed: Int) throws {
        guard position >= 0 && position <= 99 else {
            throw RaunchError.invalidPositionValue
        }
        
        guard speed >= 20 && speed <= 99 else {
            throw RaunchError.invalidSpeedValue
        }
        
        self.time = time
        self.position = position
        self.speed = speed
    }
    
}

// Display Raunch commands as strings.
extension RaunchCommand: CustomStringConvertible {
    
    var description: String {
        return "[position=\(position), speed=\(speed))"
    }
    
}

/// A Raunch content track.
final class RaunchTrack {
    
    /// The track's commands.
    var commands: [RaunchCommand]
    
    /// Creates a Raunch content track.
    /// - Parameter commands: The track's timed commands.
    init(commands: [RaunchCommand]) {
        self.commands = commands
    }
    
}
