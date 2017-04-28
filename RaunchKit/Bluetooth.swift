//
//  Bluetooth.swift
//  Raunch
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import os
import Foundation
import CoreBluetooth

/// A Bluetooth connectivity manager.
class Bluetooth: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // UUIDs.
    private let toyServiceUUID = CBUUID(string: "88F80580-0000-01E6-AACE-0002A5D5C51B")
    private let toyCommandsCharacteristicUUID = CBUUID(string: "88F80581-0000-01E6-AACE-0002A5D5C51B")
    private let toyStatusCharacteristicUUID = CBUUID(string: "88F80582-0000-01E6-AACE-0002A5D5C51B")
    
    // Core Bluetooth objects.
    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var service: CBService?
    private var commandsCharacteristic: CBCharacteristic?
    private var statusCharacteristic: CBCharacteristic?
    
    // Is the connectivity manager active?
    private var active = true
    
    // The identifier for the target toy.
    private var selectedPeripheralIdentifier: UUID?
    
    // Use a private queue and a semaphore to coordinate start
    private let queue = DispatchQueue(label: "com.metafetish.raunch.connectivity")
    private var powerOnQueue: DispatchQueue? = DispatchQueue(label: "com.metafetish.raunch.connectivity")
    private var powerReady = DispatchSemaphore(value: 0)
    
    /// Creates a Bluetooth connectivity manager.
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: queue)
    }
    
    /// Starts the connectivity manager and connect to the first toy that is discovered.
    func start() {
        active = true
        if central.state == .poweredOn {
            os_log("Scanning for peripherals...", log: bluetooth_log, type: .debug)
            self.central.scanForPeripherals(withServices: nil, options: [:])
        }
        else {
            powerOnQueue?.async {
                self.powerReady.wait()
                self.queue.async {
                    os_log("Scanning for peripherals...", log: bluetooth_log, type: .debug)
                    self.central.scanForPeripherals(withServices: nil, options: [:])
                }
            }
        }
    }
    
    /// Stops the connectivity manager.
    func stop() {
        active = false
        if let peripheral = peripheral {
            central.cancelPeripheralConnection(peripheral)
        }
    }
   
    
    /// Sends a command to the toy.
    func send(_ command: Command) {
        guard let peripheral = peripheral,
            let commandsCharacteristic = commandsCharacteristic else {
            os_log("Not ready to send a command", log: bluetooth_log, type: .default)
            return
        }
        
        os_log("Sending %@", log: bluetooth_log, type: .default, command.description)
        peripheral.writeValue(command.asData(), for: commandsCharacteristic, type: .withResponse)
    }

    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            os_log("Central state: unknown", log: bluetooth_log, type: .debug)
        case .resetting:
            os_log("Central state: resetting", log: bluetooth_log, type: .debug)
        case .unsupported:
            os_log("Central state: unsupported", log: bluetooth_log, type: .debug)
        case .unauthorized:
            os_log("Central state: unauthorized", log: bluetooth_log, type: .debug)
        case .poweredOff:
            os_log("Central state: powered off", log: bluetooth_log, type: .debug)
        case .poweredOn:
            os_log("Central state: powered on", log: bluetooth_log, type: .debug)
            powerReady.signal()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        os_log("Did discover peripheral %@ (name: %@)", log: bluetooth_log, type: .debug, peripheral.identifier.uuidString, peripheral.name ?? "<nil>")
        
        if selectedPeripheralIdentifier == nil && peripheral.name == "Launch" || peripheral.identifier == selectedPeripheralIdentifier {
            
            os_log("Selecting toy %@", log: bluetooth_log, type: .default, peripheral.identifier.uuidString)
            self.peripheral = peripheral
            self.selectedPeripheralIdentifier = peripheral.identifier
            
            os_log("Stopping scan...", log: bluetooth_log, type: .debug)
            central.stopScan()
            
            os_log("Connecting to toy...", log: bluetooth_log, type: .default)
            central.connect(peripheral, options: [:])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        os_log("Did connect to toy", log: bluetooth_log, type: .default)
        peripheral.delegate = self
        
        os_log("Discovering services...", log: bluetooth_log, type: .default)
        peripheral.discoverServices([ toyServiceUUID ])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if let error = error {
            os_log("Toy disconnected with error: %@", log: bluetooth_log, type: .error, error.localizedDescription)
        }
        else {
            os_log("Toy disconnected", log: bluetooth_log, type: .default)
        }
        
        self.peripheral = nil
        self.service = nil
        self.commandsCharacteristic = nil
        self.statusCharacteristic = nil
        
        if active {
            os_log("Scanning for peripherals...", log: bluetooth_log, type: .debug)
            self.central.scanForPeripherals(withServices: nil, options: [:])
        }
    }
    
    // MARK: CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("Error discovering services: %@", log: bluetooth_log, type: .error, error.localizedDescription)
        }
        else {
            peripheral.services?.forEach { (service) in
                if service.uuid == toyServiceUUID {
                    
                    os_log("Discovered main service", log: bluetooth_log, type: .default)
                    self.service = service
                    
                    os_log("Discovering characteristics...", log: bluetooth_log, type: .default)
                    peripheral.discoverCharacteristics([ toyCommandsCharacteristicUUID, toyStatusCharacteristicUUID ], for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log("Error discovering characteristics: %@", log: bluetooth_log, type: .error, error.localizedDescription)

        }
        else {
            if service.uuid == toyServiceUUID {
                service.characteristics?.forEach { (characteristic) in
                    if characteristic.uuid == toyCommandsCharacteristicUUID {
                        os_log("Discovered command characteristic", log: bluetooth_log, type: .default)
                        commandsCharacteristic = characteristic
                        
                    }
                    else if characteristic.uuid == toyStatusCharacteristicUUID {
                        os_log("Discovered status characteristic", log: bluetooth_log, type: .default)
                        statusCharacteristic = characteristic
                    }
                }
                
                if let commandsCharacteristic = commandsCharacteristic {
                    os_log("Sending initial 0x0...", log: bluetooth_log, type: .debug)
                    self.peripheral?.writeValue(Data(bytes: [ 0x0 ]), for: commandsCharacteristic, type: .withResponse)
                }
            }
        }
    }
    
}
