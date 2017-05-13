//
//  Time.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-03.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// Content time.
public struct RaunchTimeInterval {
    
    /// The interval measured in milliseconds.
    internal var milliseconds: Int64
    
    /// Creates a content time value.
    /// Parameter milliseconds: The value in milliseconds
    public init(milliseconds: Int64) {
        self.milliseconds = milliseconds
    }
    
    /// A really long time.
    public static var forever = RaunchTimeInterval(milliseconds: Int64.max)
    
}

// Display Raunch time as strings.
extension RaunchTimeInterval: CustomStringConvertible {
    
    public var description: String {
        let valueInSeconds = Double(milliseconds) / 1000.0
        return String(format:"%.2f", valueInSeconds)
    }
    
}

// MARK: Operators


internal func +(left: RaunchTimeInterval, right: RaunchTimeInterval) -> RaunchTimeInterval {
    return RaunchTimeInterval(milliseconds: left.milliseconds + right.milliseconds)
}

internal func -(left: RaunchTimeInterval, right: RaunchTimeInterval) -> RaunchTimeInterval {
    return RaunchTimeInterval(milliseconds: left.milliseconds - right.milliseconds)
}

internal func <=(left: RaunchTimeInterval, right: RaunchTimeInterval) -> Bool {
    return left.milliseconds <= right.milliseconds
}

internal func <(left: RaunchTimeInterval, right: RaunchTimeInterval) -> Bool {
    return left.milliseconds < right.milliseconds
}

// MARK: Mach time

// Time utilities.

extension RaunchTimeInterval {
    
    /// Constant to use to convert from and from Mach time to absolute time in milliseconds.
    /// See https://developer.apple.com/library/content/qa/qa1398/_index.html
    static var clockToAbs: Int64 {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        return Int64(Double(info.denom) / Double(info.numer) * 1000000)
    }
    
    /// Converts from absolute time in millisecond to Mach time.
    func toMachTime() -> UInt64 {
        return UInt64(RaunchTimeInterval.clockToAbs * self.milliseconds)
    }
    
}
