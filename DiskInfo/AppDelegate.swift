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
    var statusBar = NSStatusBar.system
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()

    let icon = NSImage(named: "icon16.png")

    let timerInterval = 60.0
    var timer: Timer = Timer()

    override func awakeFromNib() {
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.button?.action = #selector(populateMenu)
        icon?.isTemplate = true
        statusBarItem.button?.image = icon

        populateMenu()

        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(populateMenu), userInfo: nil, repeats: true)
    }

    @objc func populateMenu() {
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
        menuItemQuit.action = #selector(terminateApp)
        menuItemQuit.keyEquivalent = ""
        menu.addItem(menuItemQuit)
    }

    @objc func terminateApp() {
        timer.invalidate()
        exit(0)
    }

    func getDiskInfo() -> [String] {
        let attributes = directoryFileSystemAttributes(path: "/")!
        let filesystemSize = attributes[FileAttributeKey.systemSize] as! Int
        let filesystemFreeSize = attributes[FileAttributeKey.systemFreeSize] as! Int
        let totalSize = BytesToGigaBytes(b: filesystemSize)
        let freeSize = BytesToGigaBytes(b: filesystemFreeSize)
        return [
            "Total: \(totalSize) GiB",
            "Free: \(freeSize) GiB",
            "Used: \(totalSize - freeSize) GiB",
            "Percentage used: \(Int((Double(totalSize) - Double(freeSize)) / (Double(totalSize) / 100))) %",
        ]
    }

    func directoryFileSystemAttributes(path: String) -> [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfFileSystem(forPath: path)
        } catch {
            return nil
        }
    }
    
    func BytesToGigaBytes(b: Int) -> Int {
        return b / 1024 / 1024 / 1024
    }
}

