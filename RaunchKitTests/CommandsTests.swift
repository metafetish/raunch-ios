//
//  CommandsTests.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import XCTest
@testable import RaunchKit

class CommandsTests: XCTestCase {
    
    func testCommandDataIsValid() throws {
        let command = try RaunchCommand(position: 92, speed: 42)
        let data = command.asData()
        XCTAssertEqual(data.count, 2)
        data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
            XCTAssertEqual(bytes[0], 92)
            XCTAssertEqual(bytes[1], 42)
        }
    }
    
    func testCommandThrowsOnInvalidPosition() throws {
        XCTAssertThrowsError(try RaunchCommand(position: -256, speed: 42), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidPositionValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: -1, speed: 42), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidPositionValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: 100, speed: 42), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidPositionValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: 2000, speed: 42), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidPositionValue)
        }
    }
    
    func testCommandThrowsOnInvalidSpeed() throws {
        XCTAssertThrowsError(try RaunchCommand(position: 92, speed: -25), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidSpeedValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: 92, speed: 19), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidSpeedValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: 92, speed: 100), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidSpeedValue)
        }
        XCTAssertThrowsError(try RaunchCommand(position: 92, speed: 1024), "should throw an error") { (error) in
            XCTAssert(error is RaunchError)
            XCTAssertEqual(error as? RaunchError, RaunchError.invalidSpeedValue)
        }
    }
    
}
