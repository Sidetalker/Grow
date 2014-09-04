//
//  BufferGame.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/26/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import ImageIO
import UIKit
import MobileCoreServices

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
    }
    
    @IBAction func toggleAutoBuffer(sender: AnyObject) {
        if toggleAutoBuffer.on {
            lblBufferFrames.text = "Buffer Frames: Auto"
            stepperBufferFrames.enabled = false
        }
        else {
            lblBufferFrames.text = "Buffer Frames: \(bufferFrames)"
            stepperBufferFrames.enabled = true
        }
    }
    
    @IBAction func stepRows(sender: AnyObject) {
        let stepper = sender as UIStepper
        rows = Int(stepper.value)
        lblRows.text = "Rows: \(Int(stepper.value))"
    }
    
    @IBAction func stepColumns(sender: AnyObject) {
        let stepper = sender as UIStepper
        columns = Int(stepper.value)
        lblColumns.text = "Columns: \(Int(stepper.value))"
    }
    
    @IBAction func stepPercent(sender: AnyObject) {
        let stepper = sender as UIStepper
        percent = Int(stepper.value)
        lblPercent.text = "Percentage Fill: \(Int(stepper.value))%"
    }
    
    @IBAction func stepBufferFrames(sender: AnyObject) {
        let stepper = sender as UIStepper
        bufferFrames = Int(stepper.value)
        lblBufferFrames.text = "Buffer Frames: \(Int(stepper.value))"
    }
    
    @IBAction func stepFramerate(sender: AnyObject) {
        let stepper = sender as UIStepper
        framerate = Int(stepper.value)
        lblFramerate.text = "Framerate: \(Int(stepper.value)) FPS"
    }
}

class UIBufferSettingsViewController: UIViewController {
    var gameFrames: [UIImage] = [UIImage]()
    var navController = UIBufferSettingsTableViewController()
    let myLoadView = UILoadView()
    var isGIF: Bool = false
    var isPulse = false
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var btnGenerate: UIButton!
    @IBOutlet var btnExit: UIButton!
    @IBOutlet var lblMemory: UILabel!
    
    override func viewDidLoad() {
        let myFrame = CGRectMake(self.view.frame.width / 2 - 100, self.view.frame.height / 2 - 100, 200, 200)
        myLoadView.frame = myFrame
        myLoadView.alpha = 0
        myLoadView.backgroundColor = UIColor.clearColor()
        self.containerView.addSubview(myLoadView)
    }
    
    @IBAction func btnGenerate(sender: AnyObject) {
        if btnGenerate.titleLabel?.text? == "Display" {
            self.performSegueWithIdentifier("bufferGIF", sender: self)

            return
        }
        
        isGIF = false
        
        var options =  UIAlertController(title: "Select display method", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        options.addAction(UIAlertAction(title: "Test Something!", style: UIAlertActionStyle.Default, handler: { action in
            self.runTest()
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
    
    func startLoadPulse() {
        if (!isPulse) {
            isPulse = true
            self.loadPulse()
        }
    }
    
    func endLoadPulse() {
        isPulse = false
    }
    
    func loadPulse() {
        UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn,
            animations: {() in
                self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 0.8, 0.8)
            },
            completion: {(Bool) in
                UIView.animateWithDuration(1.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                    animations: {() in
                        self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 1.25, 1.25)
                    },
                    completion: {(Bool) in
                        if self.isPulse {
                            self.loadPulse()
                        }
                })
        })
    }
    
    func runTest() {
        self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 4, 4)
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {() in
                self.myLoadView.alpha = 1
                self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 1/4, 1/4)
            },
            completion: {(Bool) in
                
        })
    }
    
    func generateForGIF() {
        generateForDisplay()
    }
    
    func generateForDisplay() {
        self.toggleButtons(false)
        
        self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 4, 4)
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
            animations: {() in
            // Old generation animation logic
//            let curFrame: CGRect = self.containerView.frame
//            let newFrame = CGRectMake(0, 0, curFrame.width, curFrame.height - 17)
//            self.containerView.frame = newFrame
//            self.progressBar.alpha = 1
            
                self.myLoadView.alpha = 1
                self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 1/4, 1/4)

            }, completion: {(Bool) in
                self.startLoadPulse()
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.buildGenerations()
        }
    }
    
    @IBAction func btnExit(sender: AnyObject) {
        if self.btnExit.titleLabel?.text? == "Exit" {
            self.dismissViewControllerAnimated(true, completion: {})
        }
        else {
            self.btnExit.setTitle("Exit", forState: UIControlState.Normal)
            self.btnGenerate.setTitle("Generate", forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "bufferSettingsEmbeded" {
            self.navController = segue.destinationViewController as UIBufferSettingsTableViewController
        }
        else if segue.identifier == "bufferGIF" {
            let destController = segue.destinationViewController as UIBufferGIFViewController
            destController.frameArr = gameFrames
        }
    }
    
    func buildGenerations() {
        gameFrames = [UIImage]()
        
        let rows = navController.rows
        let cols = navController.columns
        let percent  = navController.percent
        let frames = navController.bufferFrames
        
        var curState: ConwayGame = ConwayGame(rows: rows, cols: cols)
        
        curState.populateBoardRand(Double(percent))
        
        self.myLoadView.start()
        
        for i in 0...frames - 1 {
            gameFrames.append(curState.getBoardImage(self.view.frame.width, width: self.view.frame.width))
            
            // Old generation animation logic
//            self.progressBar.setProgress(Float(i) / Float(frames), animated: true)
            self.myLoadView.update(Int(Float(i) / Float(frames) * 100))
        }
        
        // Old generation animation logic
//        self.progressBar.setProgress(0.0, animated: true)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.endLoadPulse()
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: {() in
                    // Old generation animation logic
                    //                let curFrame: CGRect = self.containerView.frame
                    //                let newFrame = CGRectMake(0, 0, curFrame.width, curFrame.height + 17)
                    //                self.containerView.frame = newFrame
                    //                self.progressBar.alpha = 0
                    self.btnGenerate.setTitle("Display", forState: UIControlState.Normal)
                    self.btnExit.setTitle("Clear", forState: UIControlState.Normal)
                    
                    self.myLoadView.alpha = 0
                    self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 1/50, 1/50)
                },
                completion: {(Bool) in
                    self.myLoadView.transform = CGAffineTransformScale(self.myLoadView.transform, 50, 50)
                    self.toggleButtons(true)
                    self.myLoadView.stop()
            })
        })
    }
    
    func toggleButtons(onOff: Bool) {
        self.btnExit.enabled = onOff
        self.btnGenerate.enabled = onOff
    }
}

class UILoadView: UIView {
    let alphaChange: CGFloat = 0.05
    var count: NSInteger = 0
    var stateArray = [[CGFloat]](count: 10, repeatedValue: [CGFloat](count: 10, repeatedValue: 0))
    var myTimer: NSTimer = NSTimer()
    
    override func drawRect(rect: CGRect) {
        // General Declarations
        let ctx = UIGraphicsGetCurrentContext()
        
        
        // Shadow Declarations
        let shadow = UIColor.blackColor().colorWithAlphaComponent(0.7)
        let shadowOffset = CGSizeMake(0, 0)
        let shadowBlurRadius: CGFloat = 10
        
        // Draw Rectangle
        let rectanglePath = UIBezierPath(rect: CGRectMake(25, 25, 150, 150))
        CGContextSaveGState(ctx)
        CGContextSetShadowWithColor(ctx, shadowOffset, shadowBlurRadius, shadow.CGColor)
        UIColor.whiteColor().setFill()
        rectanglePath.fill()
        CGContextRestoreGState(ctx)
        
        // Draw Grid
        for row in 0...10 {
            CGContextMoveToPoint(ctx, 25, CGFloat(row) * 15 + 25)
            CGContextAddLineToPoint(ctx, 175, CGFloat(row) * 15 + 25)
            CGContextStrokePath(ctx)
        }
        
        for col in 0...10 {
            CGContextMoveToPoint(ctx, CGFloat(col) * 15 + 25, 25)
            CGContextAddLineToPoint(ctx, CGFloat(col) * 15 + 25, 175)
            CGContextStrokePath(ctx)
        }
        
        for x in 0...9 {
            for y in 0...9 {
                if stateArray[x][y] <= 0 {
                    continue
                }
                
                let curX = CGFloat(25 + 15 * x)
                let curY = CGFloat(25 + 15 * y)
                
                CGContextSetFillColorWithColor(ctx, UIColor.blackColor().colorWithAlphaComponent(stateArray[x][y]).CGColor)
                CGContextFillRect(ctx, CGRectMake(curX, curY, 15, 15))
            }
        }
    }
    
    func start() {
        stateArray = [[CGFloat]](count: 10, repeatedValue: [CGFloat](count: 10, repeatedValue: 0))
        self.update(1)
        myTimer = NSTimer(timeInterval: 1 / 30, target: self, selector: "tick", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(myTimer, forMode: NSRunLoopCommonModes)
    }
    
    func stop() {
        count = 0
        myTimer.invalidate()
    }
    
    func tick() {
        for x in 0...9 {
            for y in 0...9 {
                if stateArray[x][y] > 0 && stateArray[x][y] < 1 {
                    stateArray[x][y] += alphaChange
                }
            }
        }
        
        self.setNeedsDisplay()
    }
    
    func update(newNum: NSNumber) {
        if count == newNum {
            return
        }
        
        count = newNum
        
        var possibleSquares = [(Int, Int)]()
        
        for x in 0...9 {
            for y in 0...9 {
                if stateArray[x][y] == 0 {
                    possibleSquares.append((x, y))
                }
            }
        }
        
        if possibleSquares.count == 0 {
            return
        }
        
        sort(&possibleSquares) { (_,_) in arc4random() % 2 == 0 }
        
        stateArray[possibleSquares[0].0][possibleSquares[0].1] += alphaChange
    }
}

class UIBufferGIFViewController: UIViewController, SAVideoRangeSliderDelegate {
    var imageView: UIImageView!
    var frameArr = []
    var curIndex = 0
    var isAnimating = false
    var lastStart = 0
    var lastEnd = 0
    
    override func viewDidLoad() {
        imageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.width))
        let rangeSlider = SAVideoRangeSlider(frame: CGRectMake(10, self.view.frame.size.width + 10, self.view.frame.size.width - 20, 25), gifArray: frameArr)
        rangeSlider.delegate = self
        
        self.view.addSubview(imageView)
        self.view.addSubview(rangeSlider)
        
        imageView.image = UIImage.animatedImageWithImages(frameArr, duration: 10)
        imageView.startAnimating()
        isAnimating = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func videoRange(videoRange: SAVideoRangeSlider!, didChangeLeftPosition leftPosition: Int, rightPosition: Int) {
        imageView.stopAnimating()
        
        if leftPosition != lastStart {
            imageView.image = frameArr[leftPosition] as? UIImage
        }
        else if rightPosition != lastEnd {
            imageView.image = frameArr[rightPosition] as? UIImage
        }
        
        lastStart = leftPosition
        lastEnd = rightPosition
    }
    
    func videoRange(videoRange: SAVideoRangeSlider!, didGestureStateEndedLeftPosition leftPosition: Int, rightPosition: Int) {
        imageView.image = UIImage.animatedImageWithImages(frameArr.subarrayWithRange(NSMakeRange(leftPosition, rightPosition - 1 - leftPosition)), duration: 10)
        
        if isAnimating {
            imageView.startAnimating()
        }
    }
    
    @IBAction func btnLoadOne(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveGif() {
        let gifPath = "\(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0])/gifs/testy.gif"
        let destination = CGImageDestinationCreateWithURL(NSURL.fileURLWithPath(gifPath), kUTTypeGIF, UInt(frameArr.count), nil)
        
        println(gifPath)
        
        let frameProperties = NSDictionary.dictionaryWithObjects([NSDictionary.dictionaryWithObjects([frameArr.count], forKeys: [kCGImagePropertyGIFDelayTime], count: 0)], forKeys: [kCGImagePropertyGIFDictionary], count: 1)
        let gifProperties = NSDictionary.dictionaryWithObjects([NSDictionary.dictionaryWithObjects([NSNumber.numberWithInt(0)], forKeys: [kCGImagePropertyGIFLoopCount], count: 1)], forKeys: [kCGImagePropertyGIFDictionary], count: 1)
        
        for pic in frameArr {
            CGImageDestinationAddImage(destination, pic.CGImage, frameProperties)
        }
        
        CGImageDestinationSetProperties(destination, gifProperties)
        CGImageDestinationFinalize(destination)
    }
}