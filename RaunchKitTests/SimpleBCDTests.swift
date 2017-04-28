//
//  RaunchTests.swift
//  RaunchTests
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import XCTest
@testable import RaunchKit

class SimpleBCDTests: XCTestCase {
    
    func testSimpleBCD() {
        XCTAssertEqual((-1).raunch_toBCDByte(), nil)
        XCTAssertEqual(0.raunch_toBCDByte(), 0b00000000)
        XCTAssertEqual(5.raunch_toBCDByte(), 0b00000101)
        XCTAssertEqual(10.raunch_toBCDByte(), 0b00010000)
        XCTAssertEqual(15.raunch_toBCDByte(), 0b00010101)
        XCTAssertEqual(42.raunch_toBCDByte(), 0b01000010)
        XCTAssertEqual(99.raunch_toBCDByte(), 0b10011001)
        XCTAssertEqual(100.raunch_toBCDByte(), nil)
    }
    
}
