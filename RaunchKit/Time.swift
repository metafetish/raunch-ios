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

// Display Raunch commands as strings.
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




