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

protocol ConwayGameDelegate {
    func gameDidStart(game: ConwayGame)
    func gameDidUpdate(game: ConwayGame)
    func gameDidEnd(game: ConwayGame)
}

class ConwayGame {
    var evenGenCells = [Int8]()
    var oddGenCells = [Int8]()
    var curGen = 0
    var rows = 0
    var cols = 0

    var delegate: ConwayGameDelegate?

    init (rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.evenGenCells = [Int8](count: rows * cols, repeatedValue: 0)
        self.oddGenCells = [Int8](count: rows * cols, repeatedValue: 0)
    }
    
    func getNeighborArray(index: NSInteger) -> [NSInteger] {
        let realX = index / rows
        let realY = index / cols
        var neighborArray = [NSInteger]()
        
        for x in -1...1 {
            for y in -1...1 {
                var curNeighborX = realX + x
                var curNeighborY = realY + y
                
                if curNeighborX < 0 {
                    curNeighborX = cols - 1
                }
                else if curNeighborX == cols {
                    curNeighborX = 0
                }
                
                if curNeighborY < 0 {
                    curNeighborY = rows - 1
                }
                else if curNeighborY == rows {
                    curNeighborY = 0
                }
                
                neighborArray.append(curNeighborX * cols + curNeighborY % rows)
            }
        }
        
        return neighborArray
    }

    func populateBoardRand(percent: Double) {
        for i in Range(start:0, end: rows * cols) {
            var curRand = arc4random_uniform(100) + 1
            
            if Double(curRand) < percent {
                self.evenGenCells[i] = -1 as Int8
            }
        }
    }

    func startGame() {
        delegate?.gameDidStart(self)
    }
    
    func stopGame() {
        delegate?.gameDidEnd(self)
    }

    func updateGame() {
        delegate?.gameDidUpdate(self)
        
        for i in Range(start: 0, end: rows*cols) {
            if curGen % 2 == 0 {
                if evenGenCells[i] < 0 {
                    oddGenCells[i] = 0x30 as Int8
                }
                else {
                    oddGenCells[i] = 0x10 as Int8
                }
            }
            else {
                if oddGenCells[i] < 0 {
                    evenGenCells[i] = 0x30 as Int8
                }
                else {
                    evenGenCells[i] = 0x10 as Int8
                }
            }
        }
        
        for i in Range(start: 0, end: rows*cols) {
            if evenGenCells[i] < 0 {
                for neighbor in self.getNeighborArray(i) {
                    if curGen % 2 == 0 {
                        oddGenCells[neighbor] <<= 1
                    }
                    else {
                        evenGenCells[neighbor] <<= 1
                    }
                }
            }
        }
    }
    
    func clearBoard() {
        self.evenGenCells = [Int8](count: rows * cols, repeatedValue: 0)
        self.oddGenCells = [Int8](count: rows * cols, repeatedValue: 0)
    }

    func getBoardImage(height: CGFloat, width: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height:height), false, 0.0)
        let ctx = UIGraphicsGetCurrentContext();

        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)

        var curWidth: CGFloat = width / CGFloat(cols)
        var curHeight: CGFloat = height / CGFloat(rows)

        for row in 0...rows {
            CGContextMoveToPoint(ctx, 0.0, CGFloat(row) * curHeight)
            CGContextAddLineToPoint(ctx, width, CGFloat(row) * curHeight)
            CGContextStrokePath(ctx)
        }

        for col in 0...cols {
            CGContextMoveToPoint(ctx, CGFloat(col) * curWidth, 0.0)
            CGContextAddLineToPoint(ctx, CGFloat(col) * curWidth, height)
            CGContextStrokePath(ctx)
        }
        
        for i in Range(start: 0, end: evenGenCells.count) {
            let gridX = i / rows
            let gridY = i % cols
            
            if curGen % 2 == 0 {
                if evenGenCells[i] < 0 {
                    let curCell = CGRectMake(curWidth * CGFloat(gridX), curHeight * CGFloat(gridY), curWidth, curHeight)
                    CGContextFillRect(ctx, curCell)
                }
            }
            else {
                if oddGenCells[i] < 0 {
                    let curCell = CGRectMake(curWidth * CGFloat(gridX), curHeight * CGFloat(gridY), curWidth, curHeight)
                    CGContextFillRect(ctx, curCell)
                }
            }
        }

        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage
    }
}
