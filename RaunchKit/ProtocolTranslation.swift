//
//  ProtocolTranslation.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-09.
//  Adapted from https://github.com/funjack/launchcontrol by funjack
//  Copyright © 2017 Metafetish.
//

import Foundation

/// A Miiyoo to Raunch protocol translator.
final class MiiyooToRaunchTranslator {
    
    /// The direction the toy should move in.
    enum Direction: Int {
        
        /// Nearly all the way down.
        case down = 5
        
        /// Nearly all the way up.
        case up = 95
        
        /// Toggles the direction.
        func toggle() -> Direction {
            if self == .up {
                return .down
            }
            else {
                return .up
            }
        }
        
    }
    
    /// The Miiyoo event that was last processed.
    var previousMiiyooEvent: MiiyooEvent?
    
    /// The previous Raunch event that was sent.
    var previousRaunchEvent: RaunchEvent?
    
    /// The current speed.
    var speed = 0
    
    /// The rate-limited speed.
    var rateLimitedSpeed = 0
    
    /// The current direction.
    var direction = Direction.down
    
    /// The minimum amount of time between events in milliseconds.
    static let rateLimit = RaunchTimeInterval(milliseconds: 150)
    
    /// Processes a Miiyoo event.
    /// - Parameter event: A Miiyoo event.
    /// - Returns: A Raunch event or nil.
    func process(event: MiiyooEvent) -> RaunchEvent? {
        
        // Don't move if value did not change
        if event.value == previousMiiyooEvent?.value {
            return nil
        }
        
        // Choose new speed
        if let previousMiiyooEvent = previousMiiyooEvent {
            speed = chooseSpeed(interval: event.time - previousMiiyooEvent.time, previousSpeed: speed)
        }
        else {
            speed = chooseSpeed(interval: RaunchTimeInterval.forever, previousSpeed: 0)
        }
        previousMiiyooEvent = event
        
        // How long has it been since we fired an event?
        var intervalSinceLastEvent = RaunchTimeInterval.forever
        if let previousRaunchEvent = previousRaunchEvent {
            intervalSinceLastEvent = event.time - previousRaunchEvent.time
        }
        
        // If the event came in earlier than allowed
        if intervalSinceLastEvent <= MiiyooToRaunchTranslator.rateLimit {
            if rateLimitedSpeed == 0 {
                // Set the speed that will be used while limiter is active
                rateLimitedSpeed = speed
            }
            
            // Only trigger if the last executed Rauch event is longer ago than the current Miiyoo event.
            let previousRaunchEventTime = previousRaunchEvent?.time ?? RaunchTimeInterval(milliseconds: 0)
            if previousRaunchEventTime < event.time {
                
                // New event in the future
                let futureTime = previousRaunchEventTime + MiiyooToRaunchTranslator.rateLimit
                direction = direction.toggle()
                if let raunchEvent = try? RaunchEvent(time: futureTime, position: direction.rawValue, speed: rateLimitedSpeed) {
                    previousRaunchEvent = raunchEvent
                    return raunchEvent
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else {
            // Reset rate-limited speed
            rateLimitedSpeed = 0
            
            // New event
            direction = direction.toggle()
            if let raunchEvent = try? RaunchEvent(time: event.time, position: direction.rawValue, speed: speed) {
                previousRaunchEvent = raunchEvent
                return raunchEvent
            }
            else {
                return nil
            }
        }
    }
    
    /// Chooses a new speed based on the interval between events and the previous speed.
    private func chooseSpeed(interval: RaunchTimeInterval, previousSpeed: Int) -> Int {
        
        var speed = 0
        
        // Move with "default" speed of 50% when it has been 2000 ms or more since last event.
        if interval.milliseconds >= 2000 {
            speed = 50
        }
        // Move at the "slowest" speed of 20% when it has been 1000 ms or more since last event.
        else if interval.milliseconds >= 1000 {
            speed = 20
        }
        else {
            // Raw speed value between events is 100 - (hundredth sec + 10%)
            var rawSpeed = 100 - Int((Double(interval.milliseconds) / 10.0) * 1.1)
            if rawSpeed < 0 {
                rawSpeed = 0
            }
            
            // If raw speed is bigger than previous speed, increase speed with 1/6 of the difference
            if rawSpeed > previousSpeed {
                speed = previousSpeed + (rawSpeed - previousSpeed) / 6
            }
            // If raw speed is smaller than previous speed, decrease speed with 1/2 of the difference.
            else {
                speed = previousSpeed - rawSpeed / 2
            }
            
            // No speed under 20
            if speed < 20 {
                speed = 20
            }
            // No speed over 100
            if speed > 100 {
                speed = 100
            }
        }
        
        return speed
    }
    
}

// Miiyoo -> Raunch
extension RaunchTrack {
    
    /// Creates a Raunch content track from a Miiyoo content track.
    /// Parameter track: A Miiyoo content track.
    public convenience init(miiyooTrack: MiiyooTrack) {
        
        /// Use a MiiyooToRaunchTranslator to do the dirty work
        var events = [RaunchEvent]()
        let translator = MiiyooToRaunchTranslator()
        miiyooTrack.events.forEach { (event) in
            if let raunchEvent = translator.process(event: event) {
                events.append(raunchEvent)
            }
        }
        
        self.init(events: events)
    }
    
}
