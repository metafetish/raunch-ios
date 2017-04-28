//
//  Raunch.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-27.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// Control the Fleshlight Launch on iOS.
public class Raunch {
    
    /// A bluetooth connectivity manager.
    private static let bluetooth = Bluetooth()
    
    /// Connect and control to the first toy that is discovered.
    public static func start() {
        bluetooth.start()
    }
    
    /// Send the toy to a position.
    /// - Parameter position: The desired position of the toy. Valid values are 0-99.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 0-99.
    /// - Throws: `RaunchError.invalidPositionValue` if the position value is invalid.
    ///           `RaunchError.invalidSpeedValue` if the speed value is invalid.
    public static func position(_ position: Int, speed: Int) throws {
        let command = try Command(position: position, speed: speed)
        bluetooth.send(command)
    }
    
}
