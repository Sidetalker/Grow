//
//  BufferGame.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/26/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import UIKit

class UIBufferSettingsTableViewController: UITableViewController {
    
    var rows = 20
    var columns = 10
    var percent = 50
    var bufferFrames = 1000
    var framerate = 60
    
    @IBOutlet var lblRows: UILabel!
    @IBOutlet var lblColumns: UILabel!
    @IBOutlet var lblPercent: UILabel!
    @IBOutlet var lblBufferFrames: UILabel!
    @IBOutlet var lblFramerate: UILabel!
    
    override func viewDidLoad() {
        let scrollView: UIScrollView = self.view as UIScrollView
        NSLog("delaysContentTouches: \(scrollView.delaysContentTouches)")
    }
    
    @IBAction func stepRows(sender: AnyObject) {
        let stepper = sender as UIStepper
        lblRows.text = "Rows: \(Int(stepper.value))"
        
        NSLog("stepRows fired")
    }
    
    @IBAction func stepColumns(sender: AnyObject) {
        let stepper = sender as UIStepper
        lblColumns.text = "Columns: \(Int(stepper.value))"
        
        NSLog("stepColumns fired")
    }
    
    @IBAction func stepPercent(sender: AnyObject) {
        let stepper = sender as UIStepper
        lblPercent.text = "Percent Fill: \(Int(stepper.value))%"
        
        NSLog("stepPercent fired")
    }
    
    @IBAction func stepBufferFrames(sender: AnyObject) {
        let stepper = sender as UIStepper
        lblBufferFrames.text = "Buffer Frames: \(Int(stepper.value))"
        
        NSLog("stepBufferFrames fired")
    }
    
    @IBAction func stepFramerate(sender: AnyObject) {
        let stepper = sender as UIStepper
        lblFramerate.text = "Framerate: \(Int(stepper.value)) FPS"
        
        NSLog("stepFramerate fired")
    }
}

class UIBufferSettingsViewController: UIViewController {
    
    @IBAction func btnGenerate(sender: AnyObject) {
        NSLog("btnGenerate fired")
    }
}