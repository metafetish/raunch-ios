//
//  Threads.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-12.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

extension Thread {
    
    /// Moves the thread to the real time scheduling class.
    func moveToRealTimeSchedulingClass() {
        
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
    
}
