//
//  Tracks.swift
//  Raunch
//
//  Created by Blackboxed on 2017-05-03.
//  Copyright © 2017 Metafetish. All rights reserved.
//

import Foundation

/// A content track.
class Track {
    
    /// The track's commands
    var commands: [Command]
    
    /// Creates a content track.
    init(commands: [Command]) {
        self.commands = commands
    }
    
}
