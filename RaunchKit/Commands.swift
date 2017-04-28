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
    
    /// The desired position of the toy.
    let position: Int
    private let positionAsBCD: UInt8
    
    // The speed at which the toy should move.
    let speed: Int
    private let speedAsBCD: UInt8
    
    /// Creates a command to send to the toy.
    /// - Parameter position: The desired position of the toy. Valid values are 0-99.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 0-99.
    init(position: Int, speed: Int) throws {
        self.position = position
        guard let p = position.raunch_toBCDByte() else {
            throw RaunchError.invalidPositionValue
        }
        self.positionAsBCD = p

        self.speed = speed
        guard let s = speed.raunch_toBCDByte() else {
            throw RaunchError.invalidSpeedValue
        }
        self.speedAsBCD = s
    }
    
    /// Returns the command as a two bytes packet.
    func asData() -> Data {
        return Data(bytes: [ positionAsBCD, speedAsBCD ])
    }
    
}

extension Command: CustomStringConvertible {
    
    var description: String {
        return "[position=\(position), speed=\(speed))"
    }
    
}
