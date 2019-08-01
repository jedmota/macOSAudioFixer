//
//  DeviceListView.swift
//  AudioFixer
//
//  Created by josemota on 31/07/2019.
//

import Cocoa

class DeviceListView: NSView {
    
    let contentDevicesView = NSView.init()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let devicesLabel = NSTextField.init()
        devicesLabel.font = NSFont.systemFont(ofSize: 20, weight: .medium)
        devicesLabel.stringValue = "Devices"
        devicesLabel.isEditable = false
        devicesLabel.isBezeled = false
        devicesLabel.backgroundColor = .clear
        addSubview(devicesLabel)
        devicesLabel.translatesAutoresizingMaskIntoConstraints = false
        devicesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        devicesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        devicesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        devicesLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        addSubview(contentDevicesView)
        contentDevicesView.translatesAutoresizingMaskIntoConstraints = false
        contentDevicesView.topAnchor.constraint(equalTo: devicesLabel.bottomAnchor, constant: 10).isActive = true
        contentDevicesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        contentDevicesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        contentDevicesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
