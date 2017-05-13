//
//  Player.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-30.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import os
import Foundation

/// A content player.
public final class RaunchPlayer {
    
    /// The Bluetooth connectivity manager to use to send commands.
    private let bluetooth: Bluetooth
    
    /// The track to play.
    private let track: RaunchTrack
    
    /// The player's thread, if playing
    private var thread: RaunchPlayerThread?
    
    /// The offset to use to start playback
    private var offset: RaunchTimeInterval
    
    /// Creates a player.
    init(bluetooth: Bluetooth, track: RaunchTrack) {
        self.bluetooth = bluetooth
        self.track = track
        self.offset = RaunchTimeInterval(milliseconds: 0)
    }

    /// Start playing.
    public func play() {
        let thread = RaunchPlayerThread(bluetooth: bluetooth, track: track, offset: offset)
        thread.start()
        self.thread = thread
        os_log("Playing from %@", log: player_log, type: .default, offset.description)
    }
    
    /// Pause playing
    public func pause() {
        if let thread = thread {
            thread.cancel()
            offset = thread.elapsed
            self.thread = nil
        }
    }
    
    /// Seek to time
    public func seek(to time: RaunchTimeInterval) {
        offset = time
        if let thread = thread {
            thread.cancel()
            play()
        }
    }
    
}

/// A player thread.
final class RaunchPlayerThread: Thread {
    
    /// The Bluetooth connectivity manager to use to send commands.
    private let bluetooth: Bluetooth
    
    /// The track to play.
    let track: RaunchTrack
    
    /// The track offset at which playback started.
    private var offset: UInt64
    
    /// Create a new player thread.
    init(bluetooth: Bluetooth, track: RaunchTrack, offset: RaunchTimeInterval) {
        self.bluetooth = bluetooth
        self.track = track
        self.offset = UInt64(RaunchTimeInterval.clockToAbs * offset.milliseconds)
        
        // Index is next playable command
        index = 0
        while index < track.events.count {
            let command = track.events[index]
            if command.time.toMachTime() > self.offset {
                break
            }
            index = index + 1
        }
    }
    
    /// The index for the track command to play next.
    var index: Int
    
    /// The time at which playback started.
    private var startedAt: UInt64 = 0
    
    /// The track time elasped since the thread started
    var elapsed: RaunchTimeInterval {
        let elapsedInMachTime = mach_absolute_time() - startedAt + offset
        return RaunchTimeInterval(milliseconds: Int64(elapsedInMachTime) / RaunchTimeInterval.clockToAbs)
    }
    
    // The thread processing loop.
    override func main() {
        
        // Start playing immediately
        startedAt = mach_absolute_time()
        
        // We need high precision timers
        moveToRealTimeSchedulingClass()
        
        // Play while the thread has not been cancelled
        while !isCancelled {
            
            // Get the next command or return if we are done
            guard let event = nextEvent() else {
                return
            }
            
            // Wait until the command is ready to fire.
            let deadline = startedAt + event.time.toMachTime() - offset
            mach_wait_until(deadline)
            
            // Return immediately if the thread has been cancelled
            guard !isCancelled else {
                return
            }
            
            // Play the command
            bluetooth.send(event)
        }
    }
    
    /// Returns the first event that is in the future or nil.
    private func nextEvent() -> RaunchEvent? {
        var event: RaunchEvent? = nil
        
        while index < track.events.count {
            let ev = track.events[index]
            let elapsedInMachTime = mach_absolute_time() - startedAt + offset
            if ev.time.toMachTime() > elapsedInMachTime {
                event = ev
                index = index + 1
                break
            }
            else {
                index = index + 1
            }
        }
        
        return event
    }
    
}
