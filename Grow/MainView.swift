//
//  MainView.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/22/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import UIKit

class MainView: UIView, ConwayGameDelegate {

    var gameBoard: ConwayGame
    let btnStartStop: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    let btnReset: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var lastX = -1
    var lastY = -1
    
    required init(coder aDecoder: NSCoder) {
        self.gameBoard = ConwayGame(rows: 0, cols: 0)
        
        super.init(coder: aDecoder)
    }
    
    func configureView() {
        self.backgroundColor = UIColor.whiteColor()
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: "tapped:")
        tapGesture.numberOfTapsRequired = 0
        tapGesture.minimumPressDuration = 0
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
        
        btnStartStop.frame = CGRectMake(0, self.frame.height - 50, self.frame.width / 2, 50)
        btnStartStop.setTitle("Start", forState: UIControlState.Normal)
        btnStartStop.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnStartStop.addTarget(self, action: "startStopTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnReset.frame = CGRectMake(self.frame.width / 2, self.frame.height - 50, self.frame.width / 2, 50)
        btnReset.setTitle("Reset", forState: UIControlState.Normal)
        btnReset.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnReset.addTarget(self, action: "resetTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.addSubview(btnStartStop)
        self.addSubview(btnReset)
    }
    
    func tapped(recognizer: UILongPressGestureRecognizer) {
        var tapLocation = recognizer.locationInView(self)
        
        toggleIndexAtPoint(tapLocation)
        
        NSLog("Tap Gesture Popped (\(tapLocation.x), \(tapLocation.y))")
    }
    
    func toggleIndexAtPoint(tapLocation: CGPoint) {
        var width = self.frame.width / CGFloat(gameBoard.cols)
        var height = (self.frame.height - 50) / CGFloat(gameBoard.rows)
        
        var xIndex = Int(tapLocation.x / width)
        var yIndex = Int(tapLocation.y / height)
        
        if xIndex == lastX && yIndex == lastY {
            return
        }
        
        if yIndex > gameBoard.rows {
            return
        }
        
        lastX = xIndex
        lastY = yIndex
        
        gameBoard.board[yIndex][xIndex] = !gameBoard.board[yIndex][xIndex]
        
        self.setNeedsDisplay()
    }
    
    func startStopTapped() {
        if btnStartStop.titleLabel.text == "Start" {
            gameBoard.startGame()
            btnStartStop.setTitle("Stop", forState: UIControlState.Normal)
        }
        else if btnStartStop.titleLabel.text == "Stop" {
            gameBoard.stopGame()
            btnStartStop.setTitle("Start", forState: UIControlState.Normal)
        }
        else {
            NSLog("StartStop Button in unknown state")
        }
        
        self.setNeedsDisplay()
    }
    
    func resetTapped() {
        gameBoard.clearBoard()
        gameBoard.populateBoard(50)
        
        NSLog("Reset Tapped")
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        drawGrid(rect)
    }
    
    func drawGrid(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(ctx, 0.5)
        
        var columns = gameBoard.cols
        var rows = gameBoard.rows
        
        var width: CGFloat = rect.size.width / CGFloat(columns)
        var height: CGFloat = (rect.size.height - 50) / CGFloat(rows)
        
        for x in Range(start: 0, end: rows) {
            var curYStart: CGFloat = height * CGFloat(x)
            
            for y in Range(start: 0, end: columns) {
                var curXStart: CGFloat = width * CGFloat(y)
                var curCell = CGRectMake(curXStart, curYStart, width, height);
                
                if gameBoard.board[x][y] as NSObject == true {
                    CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
                }
                else {
                    CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                }
                
                CGContextFillRect(ctx, curCell)
                
                CGContextStrokeRect(ctx, curCell)
            }
        }
    }
    
    func gameDidStart(game: ConwayGame) {
        NSLog("ConwayGame started")
    }
    
    func gameDidUpdate(game: ConwayGame) {
//        NSLog("ConwayGame updated")
        
        self.setNeedsDisplay()
    }
    
    func gameDidEnd(game: ConwayGame) {
        NSLog("ConwayGame ended")
    }
    
}