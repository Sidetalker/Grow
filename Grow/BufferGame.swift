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
    
    var rows: Int = 20
    var columns: Int = 10
    var percent: Int = 50
    var bufferFrames: Int = 1000
    var framerate: Int = 60
    
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
        lblPercent.text = "Percent Fill: \(Int(stepper.value))%"
        
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
    var gameStates: [ConwayGame] = [ConwayGame]()
    var navController = UIBufferSettingsTableViewController()
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var btnGenerate: UIButton!
    
    @IBAction func btnGenerate(sender: AnyObject) {
        NSLog("btnGenerate fired")
        
        if btnGenerate.titleLabel.text == "Display" {
            self.performSegueWithIdentifier("bufferGenerate", sender: self)
            
            return
        }
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "bufferSettingsEmbeded" {
            self.navController = segue.destinationViewController as UIBufferSettingsTableViewController
        }
        else if segue.identifier == "bufferGenerate" {
            let destController = segue.destinationViewController as UIBufferViewController
            destController.gameStates = gameStates
        }
    }
    
    func buildGenerations() {
        gameStates = [ConwayGame]()
        
        let rows = navController.rows
        let cols = navController.columns
        let percent  = navController.percent
        let frames = navController.bufferFrames
        
        var curState: ConwayGame = ConwayGame(rows: rows, cols: cols)
        
        curState.populateBoard(Double(percent))
        
        gameStates.append(curState)
        
        for i in 0...frames - 1 {
            curState.updateGame()
            gameStates.append(curState)
            self.progressBar.setProgress(Float(i) / Float(frames), animated: true)
            
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeInterval: 0.001, sinceDate: NSDate()))
        }
        
        self.progressBar.setProgress(0.0, animated: true)
        
        UIView.animateWithDuration(1, animations: {
            let curFrame: CGRect = self.containerView.frame
            let newFrame = CGRectMake(0, 0, curFrame.width, curFrame.height + 17)
            self.containerView.frame = newFrame
            self.progressBar.alpha = 0
            self.btnGenerate.setTitle("Display", forState: UIControlState.Normal)
        })
    }
}

class UIBufferViewController: UIViewController {
    var bufferPlaybackViewController: UIBufferPlaybackViewController
    var gameStates = [ConwayGame]()
    
    required init(coder aDecoder: NSCoder) {
        self.bufferPlaybackViewController = UIBufferPlaybackViewController(coder: aDecoder)
        
        super.init(coder: aDecoder)
    }
    
//    override func viewDidLoad() {
//        return
//    }
}

class UIBufferPlaybackViewController: UIViewController {
    var bufferPlaybackView: UIBufferPlaybackView
    
    required init(coder aDecoder: NSCoder) {
        self.bufferPlaybackView = UIBufferPlaybackView(coder: aDecoder)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.view = self.bufferPlaybackView
    }
}

class UIBufferPlaybackView: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        drawTest(rect)
    }

    func drawTest(rect: CGRect) {
                let ctx = UIGraphicsGetCurrentContext()
                CGContextSetLineWidth(ctx, 0.5)
                CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        
                var columns = 10
                var rows = 20
        
                var width: CGFloat = rect.size.width / CGFloat(columns)
                var height: CGFloat = (rect.size.height - 50) / CGFloat(rows)
        
                // Draw the grid
                for row in 1...rows {
                    CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * height)
                    CGContextAddLineToPoint(ctx, rect.size.width, CGFloat(row) * height)
                    CGContextStrokePath(ctx)
                }
        
                for col in 1...columns {
                    CGContextMoveToPoint(ctx, CGFloat(col) * width, 0.0)
                    CGContextAddLineToPoint(ctx, CGFloat(col) * width, rect.size.height - 50)
                    CGContextStrokePath(ctx)
                }
    }
//    func drawGrid(rect: CGRect) {
//        NSLog("drawGrid started")
//        
//        let ctx = UIGraphicsGetCurrentContext()
//        CGContextSetLineWidth(ctx, 0.5)
//        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
//        
//        var columns = gameBoard.cols
//        var rows = gameBoard.rows
//        
//        var width: CGFloat = rect.size.width / CGFloat(columns)
//        var height: CGFloat = (rect.size.height - 50) / CGFloat(rows)
//        
//        // Draw the grid
//        for row in 1...rows {
//            CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * height)
//            CGContextAddLineToPoint(ctx, rect.size.width, CGFloat(row) * height)
//            CGContextStrokePath(ctx)
//        }
//        
//        for col in 1...columns {
//            CGContextMoveToPoint(ctx, CGFloat(col) * width, 0.0)
//            CGContextAddLineToPoint(ctx, CGFloat(col) * width, rect.size.height - 50)
//            CGContextStrokePath(ctx)
//        }
//        
//        for x in Range(start: 0, end: rows) {
//            var curYStart: CGFloat = height * CGFloat(x)
//            
//            for y in Range(start: 0, end: columns) {
//                if gameBoard.board[x][y].state {
//                    var curXStart: CGFloat = width * CGFloat(y)
//                    var curCell = CGRectMake(curXStart, curYStart, width, height);
//                    
//                    CGContextFillRect(ctx, curCell)
//                }
//            }
//        }
//        
//        NSLog("drawGrid ended")
//    }
}