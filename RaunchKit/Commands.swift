//
//  Commands.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A command to send to the toy.
struct Command {
    
    /// The time at which to fire the command, relative to the start of a track.
    let time: RaunchTime
    
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
    init(time: RaunchTime, position: Int, speed: Int) throws {
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
    
    /// Returns the command as a two bytes packet.
    func asData() -> Data {
        return Data(bytes: [ UInt8(position), UInt8(speed) ])
    }
    
}

// Display commands as strings.
extension Command: CustomStringConvertible {
    
    var description: String {
        return "[position=\(position), speed=\(speed))"
    }
    
}
