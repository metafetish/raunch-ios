# raunch-ios

[![Build Status](https://travis-ci.org/metafetish/raunch-ios.svg?branch=master)](https://travis-ci.org/metafetish/raunch-ios)
[![Patreon donate button](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/qdot)

Raunch is a library for controlling the Launch sex toy on iOS. The library allows developers to create applications that can control the speed and position of the device.

## Usage

```swift
import RaunchKit

// Start scanning and connect to the first available toy
Raunch.start()

// Send a command
try Raunch.position(95, speed: 20)

// Play a content track
let content = "202.13:4,202.67:0,202.94:4,203.50:0,204.24:4,204.47:1,204.74:4,206.17:0,207.67:4"
let track = RaunchTrack(miiyooTrack: MiiyooTrack(string: content))
let player = Raunch.player(for: track)
player.play()

// Generate commands
let generator = try Raunch.generator(period: RaunchTimeInterval(milliseconds: 500), speed: 50)
generator.start()
```

## Support The Project

If you find this project helpful, you
can [support Metafetish projects via Patreon](http://patreon.com/qdot)!
Every donation helps us afford more hardware to reverse, document, and
write code for!

## Disclaimer

The raunch project is in no way affiliated with Fleshlight, Kiiroo, or
any of their partners. The documentation and libraries here have been
produced via clean room reverse engineering methods, and are provided
with no guarantees, as outlined by the license agreement. Usage of
these libraries and information is in no way condoned by
aforementioned companies, and may void the warranty of your toy.

## License

tl;dr: BSD 3-Clause License

Copyright (c) 2017, Metafetish Project
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of the authors nor the names of its contributors
  may be used to endorse or promote products derived from this
  software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY The Authors ''AS IS'' AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL The Authors BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE
