//
//  AudioAddress.swift
//  AudioFixer
//
//  Created by josemota on 01/08/2019.
//

import Foundation
import CoreAudio

struct AudioAddress {
    
    static var outputDevice = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                                                         mScope: kAudioObjectPropertyScopeGlobal,
                                                         mElement: kAudioObjectPropertyElementMaster)
    static var inputDevice = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultInputDevice,
                                                        mScope: kAudioObjectPropertyScopeGlobal,
                                                        mElement: kAudioObjectPropertyElementMaster)
    
    static var devices = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                                    mScope: kAudioObjectPropertyScopeGlobal,
                                                    mElement: kAudioObjectPropertyElementMaster)
    
    struct DeviceProperties {
        static var deviceName = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceNameCFString,
                                                           mScope: kAudioObjectPropertyScopeGlobal,
                                                           mElement: kAudioObjectPropertyElementMaster)
        static var streamConfiguration = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration,
                                                                    mScope: kAudioDevicePropertyScopeInput,
                                                                    mElement: kAudioObjectPropertyElementMaster)
        
        struct Volume {
            static var masterOutputVolume = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyVolumeScalar,
                                                                       mScope: kAudioDevicePropertyScopeOutput,
                                                                       mElement: masterChannel)
            static var leftOutputVolume = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyVolumeScalar,
                                                                     mScope: kAudioDevicePropertyScopeOutput,
                                                                     mElement: leftChannel)
            static var rightOutputVolume = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyVolumeScalar,
                                                                      mScope: kAudioDevicePropertyScopeOutput,
                                                                      mElement: rightChannel)
            static var masterChannel: AudioObjectPropertyElement = 0
            static var rightChannel: AudioObjectPropertyElement = 2
            static var leftChannel: AudioObjectPropertyElement = 1
        }
    }
}
