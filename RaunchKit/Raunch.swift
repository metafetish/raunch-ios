//
//  Raunch.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-27.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// 🚀 Fleshlight Launch Control 🚀
public class Raunch {
    
    /// A Bluetooth connectivity manager.
    private static let bluetooth = Bluetooth()
    
    /// Connects and controls the first toy that is discovered.
    public static func start() {
        bluetooth.start()
    }
    
    /// Sends the toy to a position.
    /// - Parameter position: The desired position of the toy. Valid values are 0-99.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 20-99.
    /// - Throws: `RaunchError.invalidPositionValue` if the position value is invalid.
    ///           `RaunchError.invalidSpeedValue` if the speed value is invalid.
    public static func position(_ position: Int, speed: Int) throws {
        let command = try Command(time: 0, position: position, speed: speed) // Time does not matter as we'll send it immediately.
        bluetooth.send(command)
    }
    
}
