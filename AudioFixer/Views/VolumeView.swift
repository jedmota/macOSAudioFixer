//
//  VolumeView.swift
//  AudioFixer
//
//  Created by josemota on 01/08/2019.
//

import Cocoa

class VolumeView: NSView {
    
    fileprivate let sliderView = NSSlider.init(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(onSliderChange))
    var onSliderChangeEvent: ((Float)->Void)?
    
    let floatingLabel = NSTextField.init()
    var floatingConstraint: NSLayoutConstraint?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        
        let configsLabel = NSTextField.init()
        configsLabel.font = NSFont.systemFont(ofSize: 20, weight: .medium)
        configsLabel.stringValue = "Volume"
        configsLabel.isEditable = false
        configsLabel.isBezeled = false
        configsLabel.backgroundColor = .clear
        addSubview(configsLabel)
        configsLabel.translatesAutoresizingMaskIntoConstraints = false
        configsLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        configsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        configsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        configsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        let zeroPercentLabel = NSTextField.init()
        zeroPercentLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        zeroPercentLabel.stringValue = "0%"
        zeroPercentLabel.isEditable = false
        zeroPercentLabel.isBezeled = false
        zeroPercentLabel.backgroundColor = .clear
        addSubview(zeroPercentLabel)
        zeroPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        zeroPercentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        zeroPercentLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        zeroPercentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        
        sliderView.target = self
        addSubview(sliderView)
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.topAnchor.constraint(equalTo: configsLabel.bottomAnchor, constant: 10).isActive = true
        sliderView.leadingAnchor.constraint(equalTo: zeroPercentLabel.trailingAnchor, constant: 10).isActive = true
        sliderView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        sliderView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        zeroPercentLabel.centerYAnchor.constraint(equalTo: sliderView.centerYAnchor).isActive = true
        
        
        let aHundredPercentLabel = NSTextField.init()
        aHundredPercentLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        aHundredPercentLabel.stringValue = "100%"
        aHundredPercentLabel.isEditable = false
        aHundredPercentLabel.isBezeled = false
        aHundredPercentLabel.backgroundColor = .clear
        addSubview(aHundredPercentLabel)
        aHundredPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        aHundredPercentLabel.centerYAnchor.constraint(equalTo: sliderView.centerYAnchor).isActive = true
        aHundredPercentLabel.leadingAnchor.constraint(equalTo: sliderView.trailingAnchor, constant: 10).isActive = true
        aHundredPercentLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        aHundredPercentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 20).isActive = true
        
        floatingLabel.layer?.cornerRadius = 4
        floatingLabel.layer?.masksToBounds = true
        floatingLabel.alignment = .center
        floatingLabel.usesSingleLineMode = true
        floatingLabel.alphaValue = 1
        floatingLabel.font = NSFont.systemFont(ofSize: 9, weight: .medium)
        floatingLabel.stringValue = "0%"
        floatingLabel.isEditable = false
        floatingLabel.isBezeled = false//true
        floatingLabel.backgroundColor = .clear//init(white: 0.2, alpha: 0.4)
        addSubview(floatingLabel)
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        floatingLabel.topAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 2).isActive = true
        floatingLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        floatingLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingConstraint = floatingLabel.centerXAnchor.constraint(equalTo: sliderView.leadingAnchor, constant: 0)
        floatingConstraint?.isActive = true
        
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ value: Float) {
        sliderView.floatValue = value
        updateFloatingLabel()
    }
    
    @objc
    fileprivate func onSliderChange() {
        NSLog("onSliderChange \(sliderView.floatValue)")
        onSliderChangeEvent?(sliderView.floatValue)
    }
    
    fileprivate func updateFloatingLabel() {
//        var floatingValue = Double(round(100*sliderView.floatValue)/100)*100
//        NSLog("floatingValue %.2f", floatingValue)
        floatingLabel.stringValue = String.init(format: "%.2f%%", sliderView.floatValue*100.0)
//        floatingValue = sliderView.bounds.size.width*CGFloat(sliderView.floatValue)-(floatingLabel.bounds.size.width/2)
//
        floatingConstraint?.constant = sliderView.bounds.size.width*CGFloat(sliderView.floatValue)
    }
    
}
