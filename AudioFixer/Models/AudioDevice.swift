//
//  AudioDevice.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Foundation
import CoreAudio

struct AudioDevice {
    var type: AudioDeviceType
    var id: AudioDeviceID
    var name: String
}

enum AudioDeviceType {
    case output
    case input
}
