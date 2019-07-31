//
//  DeviceView.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Cocoa

class DeviceRowView: NSView {
    
    let deviceView: DeviceView = .init()
    var onSelection: (()->Void)?
    var onAdd: (()->Void)?
    let selectionButton = NSButton.init(title: "Select", target: self, action: #selector(onSelect(sender:)))
    let addButton = NSButton.init(title: "Auto-selection", target: self, action: #selector(onAdd(sender:)))
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        addSubview(deviceView)
        deviceView.translatesAutoresizingMaskIntoConstraints = false
        deviceView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        deviceView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        deviceView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        addButton.setContentHuggingPriority(.required, for: .horizontal)
        addButton.target = self
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerYAnchor.constraint(equalTo: deviceView.centerYAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        addButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        selectionButton.setContentHuggingPriority(.required, for: .horizontal)
        selectionButton.target = self
        addSubview(selectionButton)
        selectionButton.translatesAutoresizingMaskIntoConstraints = false
        selectionButton.centerYAnchor.constraint(equalTo: deviceView.centerYAnchor).isActive = true
        selectionButton.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10).isActive = true
        selectionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        selectionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        deviceView.trailingAnchor.constraint(equalTo: selectionButton.leadingAnchor, constant: -10)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func onSelect(sender: NSButton) {
        onSelection?()
    }
    
    @objc
    func onAdd(sender: NSButton) {
        onAdd?()
    }
    
}
