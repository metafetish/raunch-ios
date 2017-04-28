//
//  Errors.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A Raunch error.
public enum RaunchError: Error {
    
    /// Position value is not valid. Position must be between 0 and 99.
    case invalidPositionValue
    
    /// Speed value is not valid. Speed must be between 0 and 99.
    case invalidSpeedValue

}

// MARK: CustomNSError

extension RaunchError: CustomNSError {
    
    public static var errorDomain: String {
        return "RaunchErrorDomain"
    }
    
    public var errorCode: Int {
        switch self {
        case .invalidPositionValue:
            return 1
        case .invalidSpeedValue:
            return 2
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .invalidPositionValue:
            return "Position value is not valid. Position must be between 0 and 99."
        case .invalidSpeedValue:
            return "Speed value is not valid. Speed must be between 0 and 99."
        }
    }
    
    public var errorUserInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: localizedDescription
        ]
    }
    
}
