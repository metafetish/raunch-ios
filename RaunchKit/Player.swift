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
public class RaunchPlayer {
    
    /// The Bluetooth connectivity manager to use to send commands.
    private let bluetooth: Bluetooth
    
    /// The track to play.
    private let track: RaunchTrack
    
    /// The player's thread, if playing
    private var thread: RaunchPlayerThread?
    
    /// The offset to use to start playback
    private var offset: UInt64
    
    /// Creates a player.
    init(bluetooth: Bluetooth, track: RaunchTrack) {
        self.bluetooth = bluetooth
        self.track = track
        self.offset = 0
    }

    /// Start playing.
    public func play() {
        let thread = RaunchPlayerThread(bluetooth: bluetooth, track: track, offset: offset)
        thread.start()
        self.thread = thread
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
        offset = RaunchTimeInterval.clockToAbs * UInt64(time)
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
    init(bluetooth: Bluetooth, track: RaunchTrack, offset: UInt64) {
        self.bluetooth = bluetooth
        self.track = track
        self.offset = offset
        
        // Index is next playable command
        index = 0
        while index < track.commands.count {
            let command = track.commands[index]
            if command.time.toMachTime() > self.offset {
                break
            }
        }
    }
    
    /// The index for the track command to play next.
    var index: Int
    
    /// The time at which playback started.
    private var startedAt: UInt64 = 0
    
    /// The track time elasped since the thread started
    var elapsed: UInt64 {
        return mach_absolute_time() - startedAt + offset
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
            guard let command = nextCommand() else {
                return
            }
            
            // Wait until the command is ready to fire.
            let deadline = startedAt + command.time.toMachTime() - offset
            mach_wait_until(deadline)
            
            // Return immediately if the thread has been cancelled
            guard !isCancelled else {
                return
            }
            
            // Play the command
            bluetooth.send(command)
        }
    }
    
    /// Moves the thread to the real time scheduling class.
    private func moveToRealTimeSchedulingClass() {
        
        let threadTimeConstraintPolicyCount = MemoryLayout<thread_time_constraint_policy>.size / MemoryLayout<integer_t>.size
        var policy = thread_time_constraint_policy(
            period: 0,
            computation: UInt32(5 * RaunchTimeInterval.clockToAbs),
            constraint: UInt32(10 * RaunchTimeInterval.clockToAbs),
            preemptible: 0
        )
        
        _ = withUnsafeMutablePointer(to: &policy) {
            $0.withMemoryRebound(to: integer_t.self, capacity: threadTimeConstraintPolicyCount) {
                thread_policy_set(pthread_mach_thread_np(pthread_self()), thread_policy_flavor_t(THREAD_TIME_CONSTRAINT_POLICY), $0, mach_msg_type_number_t(threadTimeConstraintPolicyCount))
            }
        }
    }
    
    /// Returns the first command that is in the future or nil.
    private func nextCommand() -> RaunchCommand? {
        var command: RaunchCommand? = nil
        
        while index < track.commands.count {
            let cmd = track.commands[index]
            if cmd.time.toMachTime() > elapsed {
                command = cmd
                index = index + 1
                break
            }
            else {
                index = index + 1
            }
        }
        
        return command
    }
    
}

// Time utilities.
fileprivate extension RaunchTimeInterval {
    
    /// Constant to use to convert from and from Mach time to absolute time in milliseconds.
    /// See https://developer.apple.com/library/content/qa/qa1398/_index.html
    static var clockToAbs: UInt64 {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        return UInt64(Double(info.denom) / Double(info.numer) * 1000000)
    }
    
    /// Converts from absolute time in millisecond to Mach time.
    func toMachTime() -> UInt64 {
        return RaunchTimeInterval.clockToAbs * UInt64(self)
    }
    
}
