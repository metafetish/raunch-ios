//
//  Raunch.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-27.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// 🚀 Launch Control 🚀
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
        let command = try RaunchCommand(position: position, speed: speed) // Time does not matter as we'll send it immediately.
        bluetooth.send(command)
    }
    
    /// Returns a content player for a content track.
    /// - Parameter track: The content track.
    /// - Returns: A content player.
    public static func player(for track: RaunchTrack) -> RaunchPlayer {
        return RaunchPlayer(bluetooth: bluetooth, track: track)
    }
    
    /// Return a stroke generator.
    /// - Parameter period: The desired period between commands. Valid values are 150-2000.
    /// - Parameter speed: The speed at which the toy should move. Valid values are 20-99.
    /// - Parameter bottomPosition: The bottom position the generator should use.
    /// - Parameter topPosition: The top position the generator use.
    /// - Throws: `RaunchError.invalidPeriodValue` if the period valid is invalid.
    ///           `RaunchError.invalidSpeedValue` if the speed value is invalid.
    ///           `RaunchError.invalidPositionValue` if one or both of the position are invalid.
    ///           `RaunchError.topPositionLessThanBottomPositiont` if the position are incorrect.
    public static func generator(period: RaunchTimeInterval, speed: Int, bottomPosition: Int = 5, topPosition: Int = 95) throws -> RaunchGenerator {
        return try RaunchGenerator(bluetooth: bluetooth, period: period, speed: speed, bottomPosition: bottomPosition, topPosition: topPosition)
    }
}
