//
//  AppDelegate.swift
//  DiskInfo
//
//  Created by Samuel El-Borai on 26/10/15.
//  Copyright © 2015 Samuel El-Borai. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()

    let icon = NSImage(named: "icon16.png")

    let timerInterval = 60.0
    var timer: NSTimer = NSTimer()

    override func awakeFromNib() {
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.button?.action = Selector("populateMenu")
        icon?.template = true
        statusBarItem.button?.image = icon

        populateMenu()

        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: Selector("populateMenu"), userInfo: nil, repeats: true)
    }

    func populateMenu() {
        menu.removeAllItems()
        getDiskInfo().forEach({
            (info: String) in
            let menuItem : NSMenuItem = NSMenuItem()
            menuItem.title = info
            menuItem.keyEquivalent = ""
            menu.addItem(menuItem)
        })

        let menuItemQuit = NSMenuItem()
        menuItemQuit.title = "Quit DiskInfo"
        menuItemQuit.action = Selector("terminateApp")
        menuItemQuit.keyEquivalent = ""
        menu.addItem(menuItemQuit)
    }

    func terminateApp() {
        timer.invalidate()
        exit(0)
    }

    func getDiskInfo() -> [String] {
        let attributes = directoryFileSystemAttributes("/")!
        let filesystemSize = attributes[NSFileSystemSize] as! Int
        let filesystemFreeSize = attributes[NSFileSystemFreeSize] as! Int
        let totalSize = BytesToGigaBytes(filesystemSize)
        let freeSize = BytesToGigaBytes(filesystemFreeSize)
        
        return [
            "Total: \(totalSize) GiB",
            "Free: \(freeSize) GiB",
            "Used: \(totalSize - freeSize) GiB",
            "Percentage used: \(Int((Double(totalSize) - Double(freeSize)) / (Double(totalSize) / 100))) %",
        ]
    }

    func directoryFileSystemAttributes(path: String) -> [String: AnyObject]? {
        do {
            return try NSFileManager.defaultManager().attributesOfFileSystemForPath(path)
        } catch {
            return nil
        }
    }
    
    func BytesToGigaBytes(b: Int) -> Int {
        return b / 1024 / 1024 / 1024
    }
}

