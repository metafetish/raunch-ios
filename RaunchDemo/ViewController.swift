//
//  ViewController.swift
//  RaunchDemo
//
//  Created by Blackboxed on 2017-04-26.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import UIKit
import RaunchKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Raunch.start()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let position = Int(round(sender.value))
        do {
            try Raunch.position(position, speed: 99)
        }
        catch {
            debugPrint(error)
        }
    }
    
}

