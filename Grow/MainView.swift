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
        self.clearsContextBeforeDrawing = false
        self.opaque = true
        
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
        
        NSLog("Tap Gesture Popped (\(tapLocation.x), \(tapLocation.y))")
        
        toggleIndexAtPoint(tapLocation)
    }
    
    func toggleIndexAtPoint(tapLocation: CGPoint) {
        var width = self.frame.width / CGFloat(gameBoard.cols)
        var height = (self.frame.height - 50) / CGFloat(gameBoard.rows)
        
        var xIndex = Int(tapLocation.x / width)
        var yIndex = Int(tapLocation.y / height)
        
        if xIndex >= gameBoard.cols || yIndex >= gameBoard.rows {
            return
        }
        
        if xIndex == lastX && yIndex == lastY {
            return
        }
        
        if yIndex > gameBoard.rows {
            return
        }
        
        lastX = xIndex
        lastY = yIndex
        
        gameBoard.board[yIndex][xIndex].state = !gameBoard.board[yIndex][xIndex].state
        
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
        NSLog("drawGrid started")
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        var columns = gameBoard.cols
        var rows = gameBoard.rows
        
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
        
        for x in Range(start: 0, end: rows) {
            var curYStart: CGFloat = height * CGFloat(x)
            
            for y in Range(start: 0, end: columns) {
                if gameBoard.board[x][y].state {
                    var curXStart: CGFloat = width * CGFloat(y)
                    var curCell = CGRectMake(curXStart, curYStart, width, height);
                    
                    CGContextFillRect(ctx, curCell)
                }
            }
        }
        
        NSLog("drawGrid ended")
    }
    
    func gameDidStart(game: ConwayGame) {
        NSLog("ConwayGame started")
    }
    
    func gameDidUpdate(game: ConwayGame) {
        self.setNeedsDisplay()
    }
    
    func gameDidEnd(game: ConwayGame) {
        NSLog("ConwayGame ended")
    }
    
}