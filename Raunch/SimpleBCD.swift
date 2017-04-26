//
//  BCD.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// Extension to generate packed BCD integers between 0 and 99.
extension Int {
    
    /// Converts the integer to the BCD format.
    /// - Warning: Only encodes values between 0 and 99.
    /// - Returns: The integer in BCD format or nil if the integer was not in the 0-99 range.
    func raunch_toBCDByte() -> UInt8? { // tailor:disable
        
        guard self >= 0 else {
            return nil
        }
        guard self <= 99 else {
            return nil
        }
        
        return UInt8(self % 10) | UInt8(self / 10) << 4
    }
    
}
