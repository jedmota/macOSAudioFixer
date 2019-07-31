//
//  ViewModel.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Foundation

class ViewModel {
    
    let deviceInputSelectionSignal = SignalStream<AudioDevice>.init(description: "Input Device Selected", strategy: .warm(upTo: 1))
    let deviceOutputSelectionSignal = SignalStream<AudioDevice>.init(description: "Output Device Selected", strategy: .warm(upTo: 1))
    
    var autoSelection: Bool = true
    var devices: [AudioDevice] = []
    var inputDevice: AudioDevice?
    var outputDevice: AudioDevice?
    private var actionsCallback: ((_ action: ActionEnum)->Void)?
    
    var isMaster: Bool {
        get {
            return UserDefaultsWrapper.isMaster
        }
        set {
            UserDefaultsWrapper.setMaster(newValue)
        }
    }
    
    var selectedInputDevices: [String] {
        return UserDefaultsWrapper.inputSelectionArray
    }
    var selectedOutputDevices: [String] {
        return UserDefaultsWrapper.outputSelectionArray
    }
    
    enum ActionEnum {
        case deviceInputSelection(device: AudioDevice)
        case deviceOutputSelection(device: AudioDevice)
        case devicesChanged(devices: [AudioDevice])
        case configsClean
        case configsChanged
    }
    
    init() {
        AudioService.deviceInputSelectionSignal.subscribe(on: self) { [weak self] audioDevice in
            NSLog("input: \(audioDevice)")
            self?.inputDevice = audioDevice
            self?.actionsCallback?(.deviceInputSelection(device: audioDevice))
            self?.deviceInputSelectionSignal.fire(audioDevice)
            if self?.isMaster ?? false, self?.autoSelection ?? false {
                self?.autoselectInput()
            }
            self?.autoSelection = true
        }
        AudioService.deviceOutputSelectionSignal.subscribe(on: self) { [weak self] audioDevice in
            NSLog("output: \(audioDevice)")
            self?.outputDevice = audioDevice
            self?.actionsCallback?(.deviceOutputSelection(device: audioDevice))
            self?.deviceOutputSelectionSignal.fire(audioDevice)
            if self?.isMaster ?? false, self?.autoSelection ?? false {
                self?.autoselectOutput()
            }
            self?.autoSelection = true
        }
        AudioService.devicesSignal.subscribe(on: self) { [weak self] devices in
            NSLog("devices: \(devices)")
            self?.devices = devices
            self?.actionsCallback?(.devicesChanged(devices: devices))
            self?.autoselectDevices()
        }
    }
    
    func fetchData(actionsCallback: @escaping (_ action: ActionEnum)->Void) {
        self.actionsCallback = actionsCallback
    }
    
    func setAudioDevice(_ device: AudioDevice) {
        
        autoSelection = false
        var deviceId = device.id
        NSLog("selecting: \(device)")
        if device.type == .output {
            AudioService.sharedInstance.setOutputDevice(id: &deviceId)
        }else{
            AudioService.sharedInstance.setInputDevice(id: &deviceId)
        }
    }
    
    func addAudioDevice(_ device: AudioDevice) {
        if device.type == .output {
            UserDefaultsWrapper.addOutputSelectionName(device.name)
        }else{
            UserDefaultsWrapper.addInputSelectionName(device.name)
        }
        actionsCallback?(.configsChanged)
    }
    
    func autoselectDevices() {
        autoselectInput()
        autoselectOutput()
    }
    
    func autoselectInput() {
        
        for selectedDeviceName in UserDefaultsWrapper.inputSelectionArray {
            for device in devices.filter({ $0.type == .input }) {
                
                if device.name == selectedDeviceName {
                    NSLog("autoselecting: \(device)")
                    var deviceId = device.id
                    AudioService.sharedInstance.setInputDevice(id: &deviceId)
                    return
                }
            }
        }
    }
    
    func autoselectOutput() {
        
        for selectedDeviceName in UserDefaultsWrapper.outputSelectionArray {
            for device in devices.filter({ $0.type == .output }) {
                
                if device.name == selectedDeviceName {
                    NSLog("autoselecting: \(device)")
                    var deviceId = device.id
                    AudioService.sharedInstance.setOutputDevice(id: &deviceId)
                    return
                }
            }
        }
    }
    
    @objc
    func clearConfigs() {
        UserDefaultsWrapper.clearData()
        actionsCallback?(.configsClean)
    }
}
