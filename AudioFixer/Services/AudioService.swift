//
//  AudioService.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Cocoa
import CoreServices
import CoreAudio

class AudioService {
    
    static let sharedInstance = AudioService.init()
    
    enum DevicesSelectionEnum {
        case input(audioDevice: AudioDevice)
        case output(audioDevice: AudioDevice)
    }
    
    static let devicesSignal = SignalStream<[AudioDevice]>.init(description: "Devices", strategy: .warm(upTo: 1))
    static let deviceInputSelectionSignal = SignalStream<AudioDevice>.init(description: "Input Device Selected", strategy: .warm(upTo: 1))
    static let deviceOutputSelectionSignal = SignalStream<AudioDevice>.init(description: "Output Device Selected", strategy: .warm(upTo: 1))
    
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
        }
    }
    
    struct AudioListener {
        static var devices: AudioObjectPropertyListenerProc = { audioObjectId, int, pointer, rawpointer in
            AudioService.devicesSignal.fire(AudioService.sharedInstance.devices)
            return 0
        }
        
        static var output: AudioObjectPropertyListenerProc = { audioObjectId, int, pointer, rawpointer in
            
            var deviceId = AudioDeviceID()
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(audioObjectId, pointer, 0, nil, &size)
            AudioObjectGetPropertyData(audioObjectId, pointer, 0, nil, &size, &deviceId)
            
            let name: String = {
                var name: CFString = "" as CFString
                var address = AudioAddress.DeviceProperties.deviceName
                var size = UInt32(0)
                AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
                AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &name)
                return name as String
            }()
            
            let audioDevice = AudioDevice.init(type: .output, id: deviceId, name: name)
            AudioService.deviceOutputSelectionSignal.fire(audioDevice)
            return 0
        }
        
        static var input: AudioObjectPropertyListenerProc = { audioObjectId, int, pointer, rawpointer in
            
            var deviceId = AudioDeviceID()
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(audioObjectId, pointer, 0, nil, &size)
            AudioObjectGetPropertyData(audioObjectId, pointer, 0, nil, &size, &deviceId)
            
            let name: String = {
                var name: CFString = "" as CFString
                var address = AudioAddress.DeviceProperties.deviceName
                var size = UInt32(0)
                AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
                AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &name)
                return name as String
            }()
            
            let audioDevice = AudioDevice.init(type: .input, id: deviceId, name: name)
            AudioService.deviceInputSelectionSignal.fire(audioDevice)
            return 0
        }
    }
    
    func start() {
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.devices, AudioListener.devices, nil)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, AudioListener.output, nil)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, AudioListener.input, nil)
        
        AudioService.devicesSignal.fire(devices)
        AudioService.deviceInputSelectionSignal.fire(inputDevice)
        AudioService.deviceOutputSelectionSignal.fire(outputDevice)
//        print("Devices:", devices)
//        NSLog("output: \(outputDevice)")
//        NSLog("input: \(inputDevice)")
    }
    
    func stop() {
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.devices, AudioListener.devices, nil)
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, AudioListener.output, nil)
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, AudioListener.input, nil)
    }
    
    var outputDevice: AudioDevice {
        
        var deviceId = AudioDeviceID()
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioAddress.outputDevice
        var size = UInt32(0)
        AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &size)
        AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &deviceId)
        
        let name: String = {
            var name: CFString = "" as CFString
            var address = AudioAddress.DeviceProperties.deviceName
            size = UInt32(0)
            AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
            AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &name)
            return name as String
        }()
        
        return AudioDevice.init(type: .output, id: deviceId, name: name)
    }
    
    var inputDevice: AudioDevice {
        
        var deviceId = AudioDeviceID()
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioAddress.inputDevice
        var size = UInt32(0)
        AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &size)
        AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &deviceId)
        
        let name: String = {
            var name: CFString = "" as CFString
            var address = AudioAddress.DeviceProperties.deviceName
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
            AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &name)
            return name as String
        }()
        
        return AudioDevice.init(type: .input, id: deviceId, name: name)
    }
    
    var devices: [AudioDevice] {
        let objectID = AudioObjectID(kAudioObjectSystemObject)
        var address = AudioAddress.devices
        var size = UInt32(0)
        AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &size)
        var deviceIDs: [AudioDeviceID] = {
            var deviceIDs = [AudioDeviceID]()
            for _ in 0..<Int(size) / MemoryLayout<AudioDeviceID>.size {
                deviceIDs.append(AudioDeviceID())
            }
            return deviceIDs
        }()
        AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &deviceIDs)
        let devices: [AudioDevice] = {
            var devices = [AudioDevice]()
            for id in deviceIDs {
                let name: String = {
                    var name: CFString = "" as CFString
                    var address = AudioAddress.DeviceProperties.deviceName
                    var size = UInt32(0)
                    AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
                    AudioObjectGetPropertyData(id, &address, 0, nil, &size, &name)
                    return name as String
                }()
                let type: AudioDeviceType = {
                    var address = AudioAddress.DeviceProperties.streamConfiguration
                    var size = UInt32(0)
                    AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
                    let bufferList = AudioBufferList.allocate(maximumBuffers: Int(size))
                    AudioObjectGetPropertyData(id, &address, 0, nil, &size, bufferList.unsafeMutablePointer)
                    let channelCount: Int = {
                        var count = 0
                        for index in 0 ..< Int(bufferList.unsafeMutablePointer.pointee.mNumberBuffers) {
                            count += Int(bufferList[index].mNumberChannels)
                        }
                        return count
                    }()
                    free(bufferList.unsafeMutablePointer)
                    return (channelCount > 0) ? .input : .output
                }()
                let device = AudioDevice(type: type, id: id, name: name)
                devices.append(device)
            }
            return devices
        }()
        return devices
    }
    
    // MARK: Private method
    func setOutputDevice(id: inout AudioDeviceID) {
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
    }
    
    func setInputDevice(id: inout AudioDeviceID) {
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
//        UserDefaults.standard.set(id, forKey: SuohaiDefaultKeys.audioInputDeviceID)
    }
    
}
