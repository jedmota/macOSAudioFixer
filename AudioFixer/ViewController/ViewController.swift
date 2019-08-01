//
//  ViewController.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Cocoa

class ViewController: NSViewController, NSMenuDelegate {
    
    let viewModel = ViewModel()
    let deviceListView = DeviceListView.init(frame: .zero)
    let configurationView = ConfigurationView.init(frame: .zero)
    let volumeView = VolumeView.init(frame: .zero)
    
    override func loadView() {
        super.loadView()
        
        volumeView.onSliderChangeEvent = { [weak self] volume in
            self?.viewModel.setVolume(scalar: volume)
        }
        view.addSubview(volumeView)
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        volumeView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        volumeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        volumeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        volumeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        configurationView.setMaster(viewModel.isMaster)
        configurationView.onMasterEvent = { [weak self] master in
            self?.viewModel.isMaster = master
        }
        configurationView.onClearConfigsEvent = { [weak self] in
            self?.viewModel.clearConfigs()
        }
        view.addSubview(configurationView)
        configurationView.translatesAutoresizingMaskIntoConstraints = false
        configurationView.topAnchor.constraint(equalTo: volumeView.bottomAnchor, constant: 20).isActive = true
        configurationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        configurationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        configurationView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        view.addSubview(deviceListView)
        deviceListView.translatesAutoresizingMaskIntoConstraints = false
        deviceListView.topAnchor.constraint(equalTo: configurationView.bottomAnchor, constant: 20).isActive = true
        deviceListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        deviceListView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        deviceListView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData { [weak self] action in
            
            switch action {
            case .devicesChanged(_):
                self?.reloadDevicesViews()
                break
            case .deviceOutputSelection(_):
                break
            case .deviceInputSelection(_):
                break
            case .configsClean:
                self?.reloadSequenceConfigsLabels()
                break
            case .configsChanged:
                self?.reloadSequenceConfigsLabels()
                break
            case .volumeChanged(let scalar):
                self?.volumeView.setValue(scalar)
                break
            }
        }
        reloadSequenceConfigsLabels()
    }
    
    func reloadSequenceConfigsLabels() {
        
        configurationView.configOutputSequenceDeviceView.setDevice(.Speaker(title: viewModel.selectedOutputDevices.reduce("", { "\($0) [\($1)]" })))
        configurationView.configInputSequenceDeviceView.setDevice(.Microphone(title: viewModel.selectedInputDevices.reduce("", { "\($0) [\($1)]" })))
    }
    
    func reloadDevicesViews() {
        
        deviceListView.contentDevicesView.subviews.forEach({ subview in
            subview.removeFromSuperview()
            subview.constraints.forEach({ subview.removeConstraint($0) })
        })
        loadOutputViews()
        loadInputViews()
    }
    
    func loadOutputViews() {
        
        var nextTopAnchor = deviceListView.contentDevicesView.subviews.last?.bottomAnchor ?? deviceListView.contentDevicesView.topAnchor
        var nextTopConstant: CGFloat = 5
        for item in viewModel.devices.filter({ $0.type == .output }) {
            
            let deviceRowView = DeviceRowView.init()
            deviceRowView.selectionButton.isEnabled = item.id != viewModel.outputDevice?.id
            deviceRowView.onSelection = { [weak self] in
                self?.viewModel.setAudioDevice(item)
            }
            deviceRowView.onAdd = { [weak self] in
                self?.viewModel.addAudioDevice(item)
            }
            deviceRowView.deviceView.setDevice(.Speaker(title: item.name))
//            deviceView.label.stringValue = "[\(item.type == .input ? "INPUT" : "OUTPUT")] \(item.name)"
            deviceListView.contentDevicesView.addSubview(deviceRowView)
            deviceRowView.translatesAutoresizingMaskIntoConstraints = false
            deviceRowView.topAnchor.constraint(equalTo: nextTopAnchor, constant: nextTopConstant).isActive = true
            deviceRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            deviceRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            deviceRowView.bottomAnchor.constraint(equalTo: deviceRowView.deviceView.imageView.bottomAnchor, constant: 5).isActive = true
            
            viewModel.deviceOutputSelectionSignal.subscribe(on: deviceRowView.superview!) { audioDevice in
                deviceRowView.selectionButton.isEnabled = item.id != audioDevice.id
            }
            
            nextTopAnchor = deviceRowView.bottomAnchor
            nextTopConstant = 5
        }
    }
    
    func loadInputViews() {
        
        var nextTopAnchor = deviceListView.contentDevicesView.subviews.last?.bottomAnchor ?? deviceListView.contentDevicesView.topAnchor
        var nextTopConstant: CGFloat = 25
        for item in viewModel.devices.filter({ $0.type == .input }) {
            
            let deviceRowView = DeviceRowView.init()
            deviceRowView.selectionButton.isEnabled = item.id != viewModel.inputDevice?.id
            deviceRowView.onSelection = { [weak self] in
                self?.viewModel.setAudioDevice(item)
            }
            deviceRowView.onAdd = { [weak self] in
                self?.viewModel.addAudioDevice(item)
            }
            deviceRowView.deviceView.setDevice(.Microphone(title: item.name))
//            deviceView.label.stringValue = "[\(item.type == .input ? "INPUT" : "OUTPUT")] \(item.name)"
            deviceListView.contentDevicesView.addSubview(deviceRowView)
            deviceRowView.translatesAutoresizingMaskIntoConstraints = false
            deviceRowView.topAnchor.constraint(equalTo: nextTopAnchor, constant: nextTopConstant).isActive = true
            deviceRowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            deviceRowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            deviceRowView.bottomAnchor.constraint(equalTo: deviceRowView.deviceView.imageView.bottomAnchor, constant: 5).isActive = true
            
            viewModel.deviceInputSelectionSignal.subscribe(on: deviceRowView.superview!) { audioDevice in
                deviceRowView.selectionButton.isEnabled = item.id != audioDevice.id
            }
            
            nextTopAnchor = deviceRowView.bottomAnchor
            nextTopConstant = 5
        }
    }

}

