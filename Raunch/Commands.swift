//
//  Commands.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A command to send to the Launch.
struct Command {
    
    private let position: UInt8
    private var speed: UInt8
    
    /// Creates a command to send to the Launch.
    /// - Parameter position: The desired position of the toy. Valid values are 0-99.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 0-99.
    init(position: Int, speed: Int) throws {
        guard let p = position.raunch_toBCDByte() else {
            throw RaunchError.invalidPositionValue
        }
        self.position = p

        guard let s = speed.raunch_toBCDByte() else {
            throw RaunchError.invalidSpeedValue
        }
        self.speed = s
    }
    
    /// Returns the command as a two bytes packet.
    func asData() -> Data {
        return Data(bytes: [ position, speed ])
    }
    
}
