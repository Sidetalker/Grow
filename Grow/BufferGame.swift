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
    
    var rows: Int = 50
    var columns: Int = 25
    var percent: Int = 50
    var bufferFrames: Int = 500
    var framerate: Int = 10
    
    @IBOutlet var lblRows: UILabel!
    @IBOutlet var lblColumns: UILabel!
    @IBOutlet var lblPercent: UILabel!
    @IBOutlet var lblBufferFrames: UILabel!
    @IBOutlet var lblFramerate: UILabel!
    @IBOutlet var toggleAutoBuffer: UISwitch!
    @IBOutlet var stepperBufferFrames: UIStepper!
    
    override func viewDidLoad() {
        let scrollView: UIScrollView = self.view as UIScrollView
        NSLog("delaysContentTouches: \(scrollView.delaysContentTouches)")
    }
    
    @IBAction func toggleAutoBuffer(sender: AnyObject) {
        if toggleAutoBuffer.on {
            lblBufferFrames.text = "Buffer Frames: Auto"
            stepperBufferFrames.enabled = false
        }
        else
        {
            lblBufferFrames.text = "Buffer Frames: \(bufferFrames)"
            stepperBufferFrames.enabled = true
        }
    }
    
    @IBAction func stepRows(sender: AnyObject) {
        let stepper = sender as UIStepper
        rows = Int(stepper.value)
        lblRows.text = "Rows: \(Int(stepper.value))"
        
        NSLog("stepRows fired")
    }
    
    @IBAction func stepColumns(sender: AnyObject) {
        let stepper = sender as UIStepper
        columns = Int(stepper.value)
        lblColumns.text = "Columns: \(Int(stepper.value))"
        
        NSLog("stepColumns fired")
    }
    
    @IBAction func stepPercent(sender: AnyObject) {
        let stepper = sender as UIStepper
        percent = Int(stepper.value)
        lblPercent.text = "Percentage Fill: \(Int(stepper.value))%"
        
        NSLog("stepPercent fired")
    }
    
    @IBAction func stepBufferFrames(sender: AnyObject) {
        let stepper = sender as UIStepper
        bufferFrames = Int(stepper.value)
        lblBufferFrames.text = "Buffer Frames: \(Int(stepper.value))"
        
        NSLog("stepBufferFrames fired")
    }
    
    @IBAction func stepFramerate(sender: AnyObject) {
        let stepper = sender as UIStepper
        framerate = Int(stepper.value)
        lblFramerate.text = "Framerate: \(Int(stepper.value)) FPS"
        
        NSLog("stepFramerate fired")
    }
}

class UIBufferSettingsViewController: UIViewController {
    var gameStates: [[[Cell]]] = [[[Cell]]]()
    var navController = UIBufferSettingsTableViewController()
    var isGIF: Bool = false
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var btnGenerate: UIButton!
    @IBOutlet var btnExit: UIButton!
    @IBOutlet var lblMemory: UILabel!
    
    @IBAction func btnGenerate(sender: AnyObject) {
        NSLog("btnGenerate fired")
        
        if btnGenerate.titleLabel.text == "Display" {
            self.performSegueWithIdentifier("bufferGenerate", sender: self)
            return
        }
        
        var options =  UIAlertController(title: "Select display method", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        options.addAction(UIAlertAction(title: "Play in App", style: UIAlertActionStyle.Default, handler: { action in
            self.generateForDisplay()
        }))
        
        options.addAction(UIAlertAction(title: "Generate GIF", style: UIAlertActionStyle.Default, handler: { action in
            self.generateForGIF()
        }))
        
        options.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { action in
            return
        }))
        
        self.presentViewController(options, animated: true, completion: { (Void) in
                return
            })
    }
    
    func generateForGIF() {
        isGIF = true
    }
    
    func generateForDisplay() {
        isGIF = false
        
        UIView.animateWithDuration(1, animations: {
            let curFrame: CGRect = self.containerView.frame
            let newFrame = CGRectMake(0, 0, curFrame.width, curFrame.height - 17)
            self.containerView.frame = newFrame
            self.progressBar.alpha = 1
        })
        
        dispatch_async(dispatch_get_main_queue()) {
            self.buildGenerations()
        }
    }
    
    @IBAction func btnExit(sender: AnyObject) {
        if self.btnExit.titleLabel.text == "Exit" {
            self.dismissViewControllerAnimated(true, completion: {})
        }
        else {
            self.gameStates = [[[Cell]]]()
            self.btnExit.setTitle("Exit", forState: UIControlState.Normal)
            self.btnGenerate.setTitle("Generate", forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "bufferSettingsEmbeded" {
            self.navController = segue.destinationViewController as UIBufferSettingsTableViewController
        }
        else if segue.identifier == "bufferGenerate" {
            let destController = segue.destinationViewController as UIBufferViewController
            destController.gameStates = gameStates
            destController.framerate = navController.framerate
        }
    }
    
    func buildGenerations() {
        gameStates = [[[Cell]]]()
        
        let rows = navController.rows
        let cols = navController.columns
        let percent  = navController.percent
        let frames = navController.bufferFrames
        
        var curState: ConwayGame = ConwayGame(rows: rows, cols: cols)
        
        curState.populateBoard(Double(percent))
        
        gameStates.append(curState.board)
        
        for i in 0...frames - 2 {
            let changesMade = curState.updateGame()
            
            if navController.toggleAutoBuffer.on && !changesMade {
                break
            }
            
            if !changesMade {
                NSLog("No changes made but buffer break didn't fire")
            }
            
            gameStates.append(curState.board)
            self.progressBar.setProgress(Float(i) / Float(frames), animated: true)
            
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeInterval: 0.001, sinceDate: NSDate()))
        }
        
        self.progressBar.setProgress(0.0, animated: true)
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() in
                let curFrame: CGRect = self.containerView.frame
                let newFrame = CGRectMake(0, 0, curFrame.width, curFrame.height + 17)
                self.containerView.frame = newFrame
                self.progressBar.alpha = 0
                self.btnGenerate.setTitle("Display", forState: UIControlState.Normal)
                self.btnExit.setTitle("Clear", forState: UIControlState.Normal)
            },
            completion: {(Bool) in
                self.btnGenerate.enabled = true
                self.btnExit.enabled = true
        })
        
    }
    
    func toggleButtons(onOff: Bool) {
        self.btnExit.enabled = onOff
        self.btnGenerate.enabled = onOff
    }
}

class UIBufferViewController: UIViewController {
    var playbackVC: UIBufferPlaybackViewController?
    var gameStates: [[[Cell]]] = [[[Cell]]]()
    var framerate = 0
    
    @IBOutlet var lblFPS: UILabel!
    @IBOutlet var lblFrame: UILabel!
    @IBOutlet var lblSquares: UILabel!
    @IBOutlet var btnStart: UIButton!
    
    @IBAction func btnStartPressed(sender: AnyObject) {
        if self.btnStart.titleLabel.text == "Start" {
            self.btnStart.setTitle("Stop", forState: UIControlState.Normal)
            playbackVC?.startPlayback()
        }
        else {
            self.btnStart.setTitle("Start", forState: UIControlState.Normal)
            playbackVC?.stopPlayback()
        }
    }
    
    @IBAction func btnDismissPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        NSLog("UIBufferViewController frame height: \(self.view.frame.size.height)")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "bufferPlaybackEmbedded" {
            let destController = segue.destinationViewController as UIBufferPlaybackViewController
            destController.gameStates = gameStates
            destController.framerate = framerate
            destController.mainVC = self
            self.playbackVC = destController
        }
    }
}

class UIBufferPlaybackViewController: UIViewController {
    var mainVC: UIBufferViewController?
    var bufferPlaybackView: UIBufferPlaybackView = UIBufferPlaybackView()
    var framerate = 0
    var gameStates: [[[Cell]]] = [[[Cell]]]()

    override func viewDidLoad() {
        if mainVC == nil {
            NSLog("mainVC is nil in UIBufferPlaybackViewController")
        }
        
        self.mainVC?.lblFPS.text = "FPS: \(framerate)"
        self.bufferPlaybackView.gameStates = gameStates
        self.bufferPlaybackView.framerate = framerate
        self.bufferPlaybackView.mainVC = mainVC
        self.bufferPlaybackView.backgroundColor = UIColor.whiteColor()
        self.view = self.bufferPlaybackView
    }
    
    func startPlayback() {
        bufferPlaybackView.playbackTimer = NSTimer.scheduledTimerWithTimeInterval(1 / Double(framerate), target: bufferPlaybackView, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func stopPlayback() {
        bufferPlaybackView.playbackTimer.invalidate()
    }
}

class UIBufferPlaybackView: UIView {
    var mainVC: UIBufferViewController? 
    var gameStates: [[[Cell]]] = [[[Cell]]]()
    var framerate = 0
    var curIndex = 0
    var lastTime = NSDate()
    var playbackTimer = NSTimer()
    
    override func drawRect(rect: CGRect) {
        NSLog("UIBufferPlaybackView rect height: \(rect.size.height)")
        
        drawGrid(rect)
    }
    
    func tick() {
        curIndex++
        self.setNeedsDisplay()
    }
    
    func gridTest(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        var columns = 10
        var rows = 20
        
        var width: CGFloat = rect.size.width / CGFloat(columns)
        var height: CGFloat = rect.size.height / CGFloat(rows)
        
        for row in 1...rows {
            CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * height)
            CGContextAddLineToPoint(ctx, rect.size.width, CGFloat(row) * height)
            CGContextStrokePath(ctx)
        }
        
        for col in 1...columns {
            CGContextMoveToPoint(ctx, CGFloat(col) * width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(col) * width, rect.size.height)
            CGContextStrokePath(ctx)
        }
    }
    
    func drawGrid(rect: CGRect) {
        if curIndex >= gameStates.count {
            playbackTimer.invalidate()
            curIndex--
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        let thisTime = NSDate()
        let FPSText = NSString(format: "%.2f", 1 / thisTime.timeIntervalSinceDate(lastTime))
        
        mainVC?.lblFPS.text = "FPS: " + FPSText
        mainVC?.lblFrame.text = "Frame: \(curIndex + 1)/\(gameStates.count)"
        lastTime = thisTime
    
        let curBoard = gameStates[curIndex]
        
        var rows = curBoard.count
        var columns = curBoard[0].count
        
        var width: CGFloat = rect.size.width / CGFloat(columns)
        var height: CGFloat = rect.size.height / CGFloat(rows)
        
        var rectCount = 0
        
        // Draw the grid
        for row in 1...rows {
            CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * height)
            CGContextAddLineToPoint(ctx, rect.size.width, CGFloat(row) * height)
            CGContextStrokePath(ctx)
        }
        
        for col in 1...columns {
            CGContextMoveToPoint(ctx, CGFloat(col) * width, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(col) * width, rect.size.height)
            CGContextStrokePath(ctx)
        }
        
        for x in Range(start: 0, end: rows) {
            var curYStart: CGFloat = height * CGFloat(x)
            
            for y in Range(start: 0, end: columns) {
                if curBoard[x][y].state {
                    var curXStart: CGFloat = width * CGFloat(y)
                    var curCell = CGRectMake(curXStart, curYStart, width, height);
                    
                    CGContextFillRect(ctx, curCell)
                    rectCount++
                }
            }
        }
        
        curIndex++
        mainVC?.lblSquares.text = "Squares: \(rectCount)"
    }
}