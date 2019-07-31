//
//  ConfigurationView.swift
//  AudioFixer
//
//  Created by josemota on 31/07/2019.
//

import Cocoa

class ConfigurationView: NSView {
    
    let configOutputSequenceDeviceView = DeviceView.init()
    let configInputSequenceDeviceView = DeviceView.init()
    private let masterCheckButton = NSButton.init(checkboxWithTitle: "Set as Master", target: self, action: #selector(onSetAsMaster(sender:)))
    
    var onClearConfigsEvent: (()->Void)?
    var onMasterEvent: ((Bool)->Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let configsLabel = NSTextField.init()
        configsLabel.font = NSFont.systemFont(ofSize: 20, weight: .medium)
        configsLabel.stringValue = "Auto-Selection Configuration:"
        configsLabel.isEditable = false
        configsLabel.isBezeled = false
        configsLabel.backgroundColor = .clear
        addSubview(configsLabel)
        configsLabel.translatesAutoresizingMaskIntoConstraints = false
        configsLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        configsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        configsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        configsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        addSubview(configOutputSequenceDeviceView)
        configOutputSequenceDeviceView.translatesAutoresizingMaskIntoConstraints = false
        configOutputSequenceDeviceView.topAnchor.constraint(equalTo: configsLabel.bottomAnchor, constant: 10).isActive = true
        configOutputSequenceDeviceView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        configOutputSequenceDeviceView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        configOutputSequenceDeviceView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        addSubview(configInputSequenceDeviceView)
        configInputSequenceDeviceView.translatesAutoresizingMaskIntoConstraints = false
        configInputSequenceDeviceView.topAnchor.constraint(equalTo: configOutputSequenceDeviceView.bottomAnchor, constant: 10).isActive = true
        configInputSequenceDeviceView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        configInputSequenceDeviceView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        configInputSequenceDeviceView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let cleanButton = NSButton.init(title: "Clear Configs", target: self, action: #selector(onCleanConfigs(sender:)))
        cleanButton.target = self
        addSubview(cleanButton)
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        cleanButton.topAnchor.constraint(equalTo: configInputSequenceDeviceView.bottomAnchor, constant: 10).isActive = true
        cleanButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        masterCheckButton.target = self
        addSubview(masterCheckButton)
        masterCheckButton.translatesAutoresizingMaskIntoConstraints = false
        masterCheckButton.topAnchor.constraint(equalTo: cleanButton.bottomAnchor, constant: 10).isActive = true
        masterCheckButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        bottomAnchor.constraint(equalTo: masterCheckButton.bottomAnchor, constant: 20).isActive = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMaster(_ master: Bool) {
        masterCheckButton.state = master ? .on : .off
    }
    
    @objc
    fileprivate func onCleanConfigs(sender: NSButton) {
        onClearConfigsEvent?()
    }
    
    @objc
    fileprivate func onSetAsMaster(sender: NSButton) {
        onMasterEvent?(sender.state.rawValue == 1 ? true : false)
    }
    
}
