//
//  Generator.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-12.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A configuration for a stroke generator.
struct RaunchGeneratorConfiguration {
    
    /// The period between commands.
    let period: RaunchTimeInterval
    
    /// The speed to move at.
    let speed: Int
    
    /// The bottom position.
    let bottomPosition: Int
    
    /// The top position.
    let topPosition: Int
    
    /// Creates a configuration for a stroke generator.
    init(period: RaunchTimeInterval, speed: Int, bottomPosition: Int, topPosition: Int) throws {
        
        // Period
        guard period.milliseconds >= 150 && period.milliseconds <= 2000 else {
            throw RaunchError.invalidPeriodValue
        }
        self.period = period
        
        // Speed
        self.speed = try validate(speed: speed)
        
        // Positions
        guard bottomPosition < topPosition else {
            throw RaunchError.topPositionLessThanBottomPosition
        }
        self.bottomPosition = try validate(position: bottomPosition)
        self.topPosition = try validate(position: topPosition)
    }
    
}

/// A stroke generator.
public final class RaunchGenerator {
    
    /// The Bluetooth connectivity manager to use to send commands.
    private let bluetooth: Bluetooth
    
    /// The configuration for the stroke generator.
    private var configuration: RaunchGeneratorConfiguration
    
    /// The generator's thread, if playing
    private var thread: RaunchGeneratorThread?
    
    // Creates a stroke generator.
    init(bluetooth: Bluetooth, period: RaunchTimeInterval, speed: Int, bottomPosition: Int, topPosition: Int) throws {
        self.bluetooth = bluetooth
        self.configuration = try RaunchGeneratorConfiguration(period: period, speed: speed, bottomPosition: bottomPosition, topPosition: topPosition)
    }
    
    /// Starts sending generated commands.
    public func start() {
        thread = RaunchGeneratorThread(bluetooth: bluetooth, configuration: configuration)
        thread?.start()
    }
    
    /// Stops sending generator commands.
    public func stop() {
        thread?.cancel()
    }
    
}

final class RaunchGeneratorThread: Thread {
    
    /// The Bluetooth connectivity manager to use to send commands.
    private let bluetooth: Bluetooth
    
    /// The configuration for the stroke generator.
    private var configuration: RaunchGeneratorConfiguration
    
    /// Create a new player thread.
    init(bluetooth: Bluetooth, configuration: RaunchGeneratorConfiguration) {
        self.bluetooth = bluetooth
        self.configuration = configuration
    }
    
    /// The current direction.
    private var direction = Direction.down
    
    /// The time at which playback started.
    private var startedAt: UInt64 = 0
    
    /// The command count
    private var count: UInt64 = 0
    
    // The thread processing loop.
    override func main() {
        
        // We need high precision timers
        moveToRealTimeSchedulingClass()
        
        // Start playing immediately
        startedAt = mach_absolute_time()
        
        // Play while the thread has not been cancelled
        while !isCancelled {
            
            // Play command
            if let command = try? RaunchCommand(position: nextPosition(), speed: configuration.speed) {
                bluetooth.send(command)
            }
            count = count + 1
            
            // Wait the right amout of time
            let deadline = startedAt + count * configuration.period.toMachTime()
            mach_wait_until(deadline)
        }
    }
    
    /// The direction the toy should move in.
    enum Direction {
        
        /// Down
        case down
        
        /// Up
        case up
        
    }
    
    /// The next position the toy should use
    func nextPosition() -> Int {
        if direction == .down {
            direction = .up
            return configuration.topPosition
        }
        else {
            direction = .down
            return configuration.bottomPosition
        }
    }
    
}
