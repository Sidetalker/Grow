//
//  ConwayGame.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/25/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

struct Coord {
    var x: Int
    var y: Int
}

struct Cell {
    var neighbors: Int
    var state: Bool
    var changed: Bool
}

protocol ConwayGameDelegate {
    func gameDidStart(game: ConwayGame)
    func gameDidUpdate(game: ConwayGame)
    func gameDidEnd(game: ConwayGame)
}

class ConwayGame {
    var stateTracker = [Coord]()
    var board = [[Cell]]()
    var updater: NSTimer = NSTimer()
    var rows = 0
    var cols = 0
    var fps: Double = 1/60.0
    
    var delegate: ConwayGameDelegate?
    
    init (rows: Int, cols: Int) {
        self.board = [[Cell]](count: rows, repeatedValue: [Cell](count: cols, repeatedValue: Cell(neighbors: 0, state: false, changed: true)))
        self.rows = rows
        self.cols = cols
    }
    
    func populateBoard (percent: Double) {
        for x in Range(start: 0, end: rows) {
            for y in Range(start: 0, end: cols) {
                var curRand = arc4random_uniform(100) + 1
                
                if Double(curRand) < percent {
                    toggleCell(x, yLoc: y, board: &board)
                }
            }
        }
    }
    
    func toggleCell(xLoc: Int, yLoc: Int, inout board: [[Cell]]) {
        let original = board[xLoc][yLoc].state
        
        board[xLoc][yLoc].state = !board[xLoc][yLoc].state
        
        for x in -1...1 {
            for y in -1...1 {
                if (xLoc + x) < 0 || (xLoc + x) >= rows || (yLoc + y) < 0 || (yLoc + y) >= cols {
                    continue
                }
                
                if x == 0 && y == 0 {
                    continue
                }
                
                let startingNeighbors = board[x + xLoc][y + yLoc].neighbors
                let startingState = board[x + xLoc][y + yLoc].state
                
                if original {
                    board[x + xLoc][y + yLoc].neighbors--
                }
                else {
                    board[x + xLoc][y + yLoc].neighbors++
                }
                
                if startingState {
                    if board[x + xLoc][y + yLoc].neighbors < 2 || board[x + xLoc][y + yLoc].neighbors > 3 {
                        board[x + xLoc][y + yLoc].changed = true
                    }
                }
                else {
                    if board[x + xLoc][y + yLoc].neighbors == 3
                    {
                        board[x + xLoc][y + yLoc].changed = true
                    }
                }
            }
        }
    }
    
    func clearBoard() {
        self.board = [[Cell]](count: rows, repeatedValue: [Cell](count: cols, repeatedValue: Cell(neighbors: 0, state: false, changed: true)))
    }
    
    func startGame() {
        delegate?.gameDidStart(self)
        
        updater = NSTimer.scheduledTimerWithTimeInterval(fps, target: self, selector: Selector("updateGame"), userInfo: nil, repeats: true)
    }
    
    @objc func updateGame() -> Bool {
        delegate?.gameDidUpdate(self)
        
//        NSLog("Game Update Calculation Begin")
        
//        Any live cell with fewer than two live neighbours dies, as if caused by under-population.
//        Any live cell with two or three live neighbours lives on to the next generation.
//        Any live cell with more than three live neighbours dies, as if by overcrowding.
//        Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard: [[Cell]] = board
        var allDead = true
        var updated = false
        
        for x in Range(start: 0, end: rows) {
            for y in Range(start: 0, end: cols) {
                if !board[x][y].changed {
                    continue
                }
        
                var neighborCount = board[x][y].neighbors
                
                if board[x][y].state == true {
                    allDead = false
                    
                    if neighborCount < 2 || neighborCount > 3 {
                        toggleCell(x, yLoc: y, board: &newBoard)
                        updated = true
                    }
                }
                else {
                    if neighborCount == 3 {
                        toggleCell(x, yLoc: y, board: &newBoard)
                        updated = true
                    }
                }
            }
        }
        
        if allDead {
            updater.invalidate()
        }
        
        board = newBoard
        
        return updated
    }
    
    func stopGame() {
        updater.invalidate()
        
        delegate?.gameDidEnd(self)
    }
    
    func getBoardImage(height: CGFloat, width: CGFloat) -> UIImage {
        let myBoard = board
        
        if myBoard.count < 1 {
            return UIImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height:height), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        
        let rows = myBoard.count
        let columns = myBoard[0].count
        
        var curWidth: CGFloat = width / CGFloat(columns)
        var curHeight: CGFloat = height / CGFloat(rows)
        
        for row in 0...rows {
            CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * curHeight)
            CGContextAddLineToPoint(ctx, width, CGFloat(row) * curHeight)
            CGContextStrokePath(ctx)
        }
        
        for col in 0...columns {
            CGContextMoveToPoint(ctx, CGFloat(col) * curWidth, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(col) * curWidth, height)
            CGContextStrokePath(ctx)
        }
        
        for x in Range(start: 0, end: rows) {
            var curYStart: CGFloat = curHeight * CGFloat(x)
            
            for y in Range(start: 0, end: columns) {
                if myBoard[x][y].state {
                    var curXStart: CGFloat = curWidth * CGFloat(y)
                    var curCell = CGRectMake(curXStart, curYStart, curWidth, curHeight);
                    
                    CGContextFillRect(ctx, curCell)
                }
            }
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}
