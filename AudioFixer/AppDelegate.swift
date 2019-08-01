//
//  AppDelegate.swift
//  AudioFixer
//
//  Created by josemota on 30/07/2019.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow?
    var preferencesViewController: NSViewController?
    
    var windowController : NSWindowController?
    
    @IBAction func preferencesClickEvent(_ sender: NSMenuItem) {
//        reopenWindow()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        AudioService.sharedInstance.start()
        
        if let window = NSApplication.shared.mainWindow {
            self.window = window
            if let viewController = window.contentViewController as? ViewController {
                self.preferencesViewController = viewController
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        AudioService.sharedInstance.stop()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//        reopenWindow()
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func reopenWindow() {
        
        let mainStoryBoard = NSStoryboard(name: "Main", bundle: nil)
        windowController = mainStoryBoard.instantiateController(withIdentifier: "windowController") as? NSWindowController
        windowController?.showWindow(self)
    }

}

