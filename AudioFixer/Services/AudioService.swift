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
    static let volumeOutputSignal = SignalStream<Float>.init(description: "Volume Output selection", strategy: .warm(upTo: 1))
    
    init() {
        self.outputDevice = AudioDevice.init(type: .output, id: 1, name: "")
        self.inputDevice = AudioDevice.init(type: .output, id: 1, name: "")
        
        defer {
            self.inputDevice = self.getCurrentInputDevice()
            self.outputDevice = self.getCurrentOutputDevice()
        }
    }
    
    func start() {
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.devices, AudioListener.devices, nil)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, AudioListener.output, nil)
        AudioObjectAddPropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, AudioListener.input, nil)
        
        AudioService.devicesSignal.fire(devices)
        AudioService.deviceInputSelectionSignal.fire(inputDevice)
        AudioService.deviceOutputSelectionSignal.fire(outputDevice)
    }
    
    func stop() {
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.devices, AudioListener.devices, nil)
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, AudioListener.output, nil)
        AudioObjectRemovePropertyListener(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, AudioListener.input, nil)
    }
    
    var outputDevice: AudioDevice {
        didSet {
            updateVolume()
            setVolumeListeners(deviceId: outputDevice.id)
        }
    }
    
    var inputDevice: AudioDevice
    
    func getCurrentInputDevice() -> AudioDevice {
        
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
    
    func getCurrentOutputDevice() -> AudioDevice {
        
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
    
    func setVolumeListeners(deviceId: UInt32) {
        
        var data: UInt32 = 0
        var address = AudioAddress.DeviceProperties.Volume.masterOutputVolume
        AudioObjectAddPropertyListener(deviceId, &address, AudioListener.masterChannelVolume, &data)
        var leftData: UInt32 = 0
        var leftAddress = AudioAddress.DeviceProperties.Volume.leftOutputVolume
        leftAddress.mElement = AudioAddress.DeviceProperties.Volume.leftChannel
        AudioObjectAddPropertyListener(deviceId, &leftAddress, AudioListener.otherChannelVolume, &leftData)
        var rightData: UInt32 = 0
        var rightAddress = AudioAddress.DeviceProperties.Volume.rightOutputVolume
        rightAddress.mElement = AudioAddress.DeviceProperties.Volume.rightChannel
        AudioObjectAddPropertyListener(deviceId, &rightAddress, AudioListener.otherChannelVolume, &rightData)
    }
    
    func removeVolumeListeners(deviceId: UInt32) {
        
        var data: UInt32 = 0
        var address = AudioAddress.DeviceProperties.Volume.masterOutputVolume
        AudioObjectAddPropertyListener(deviceId, &address, AudioListener.masterChannelVolume, &data)
        var leftData: UInt32 = 0
        var leftAddress = AudioAddress.DeviceProperties.Volume.leftOutputVolume
        leftAddress.mElement = AudioAddress.DeviceProperties.Volume.leftChannel
        AudioObjectAddPropertyListener(deviceId, &leftAddress, AudioListener.otherChannelVolume, &leftData)
        var rightData: UInt32 = 0
        var rightAddress = AudioAddress.DeviceProperties.Volume.rightOutputVolume
        rightAddress.mElement = AudioAddress.DeviceProperties.Volume.rightChannel
        AudioObjectAddPropertyListener(deviceId, &rightAddress, AudioListener.otherChannelVolume, &rightData)
    }
    
    func updateVolume() {
        
        let deviceId = outputDevice.id
        
        let masterVolume: Float32 = {
            
            var volume: Float32 = 0
            var address = AudioAddress.DeviceProperties.Volume.masterOutputVolume
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
            AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &volume)
            return volume
        }()
        let leftVolume: Float32 = {
            
            var volume: Float32 = 0
            var address = AudioAddress.DeviceProperties.Volume.leftOutputVolume
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
            AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &volume)
            return volume
        }()
        let rightVolume: Float32 = {
            
            var volume: Float32 = 0
            var address = AudioAddress.DeviceProperties.Volume.rightOutputVolume
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
            AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &volume)
            return volume
        }()
        AudioService.volumeOutputSignal.fire(AudioService.getVolume(masterVolume: masterVolume, rightVolume: rightVolume, leftVolume: leftVolume))
    }
    
    fileprivate static func getVolume(masterVolume: Float, rightVolume: Float, leftVolume: Float) -> Float {
        return max(masterVolume, rightVolume, leftVolume)
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
        
        removeVolumeListeners(deviceId: outputDevice.id)
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.outputDevice, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
    }
    
    func setInputDevice(id: inout AudioDeviceID) {
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &AudioAddress.inputDevice, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
    }
    
    func setOutputDeviceVolume(_ scalar: Float32) {
        var value = scalar
        AudioObjectSetPropertyData(outputDevice.id, &AudioAddress.DeviceProperties.Volume.masterOutputVolume, 0, nil, UInt32(MemoryLayout<Float32>.size), &value)
        AudioObjectSetPropertyData(outputDevice.id, &AudioAddress.DeviceProperties.Volume.leftOutputVolume, 0, nil, UInt32(MemoryLayout<Float32>.size), &value)
        AudioObjectSetPropertyData(outputDevice.id, &AudioAddress.DeviceProperties.Volume.rightOutputVolume, 0, nil, UInt32(MemoryLayout<Float32>.size), &value)
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
            AudioService.sharedInstance.outputDevice = audioDevice
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
            AudioService.sharedInstance.inputDevice = audioDevice
            return 0
        }
        
        static var masterChannelVolume: AudioObjectPropertyListenerProc = { audioObjectId, int, pointer, rawpointer in
            
            var volume:Float32 = 0.5
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(audioObjectId, pointer, 0, nil, &size)
            AudioObjectGetPropertyData(audioObjectId, pointer, 0, nil, &size, &volume)
            AudioService.volumeOutputSignal.fire(volume)
            NSLog("masterVolume: \(volume)")
            return 0
        }
        
        static var otherChannelVolume: AudioObjectPropertyListenerProc = { audioObjectId, int, pointer, rawpointer in
            
            var volume:Float32 = 0.5
            var size = UInt32(0)
            AudioObjectGetPropertyDataSize(audioObjectId, pointer, 0, nil, &size)
            AudioObjectGetPropertyData(audioObjectId, pointer, 0, nil, &size, &volume)
            
            var deviceId = AudioService.sharedInstance.outputDevice.id
            let leftVolume: Float32 = {
                var volume: Float32 = 0
                var address = AudioAddress.DeviceProperties.Volume.leftOutputVolume
                var size = UInt32(0)
                AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
                AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &volume)
                return volume
            }()
            let rightVolume: Float32 = {
                
                var volume: Float32 = 0
                var address = AudioAddress.DeviceProperties.Volume.rightOutputVolume
                var size = UInt32(0)
                AudioObjectGetPropertyDataSize(deviceId, &address, 0, nil, &size)
                AudioObjectGetPropertyData(deviceId, &address, 0, nil, &size, &volume)
                return volume
            }()
            NSLog("leftVolume: \(leftVolume) rightVolume: \(rightVolume)")
            AudioService.volumeOutputSignal.fire(max(leftVolume, rightVolume))
            
            return 0
        }
    }
    
}
