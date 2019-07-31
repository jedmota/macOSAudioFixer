//
//  DeviceV.swift
//  AudioFixer
//
//  Created by josemota on 31/07/2019.
//

import Cocoa

class DeviceView: NSView {
    
    enum DeviceEnum {
        case Speaker(title: String)
        case Microphone(title: String)
        
        var image: NSImage? {
            switch self {
            case .Speaker(_):
                return NSImage.init(named: "speaker")
            case .Microphone(_):
                return NSImage.init(named: "microphone")
            }
        }
        
        var title: String {
            switch self {
            case .Speaker(let title):
                return title
            case .Microphone(let title):
                return title
            }
        }
    }
    
    let imageView = NSImageView.init()
    let label = NSTextField.init()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.font = NSFont.systemFont(ofSize: 12, weight: .regular)
        label.isEditable = false
        label.isBezeled = false
        label.backgroundColor = .clear
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDevice(_ device: DeviceEnum) {
        label.stringValue = device.title
        imageView.image = device.image
    }
    
    
}
