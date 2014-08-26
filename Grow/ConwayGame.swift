//
//  ConwayGame.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/25/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation

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
                
//                NSLog("X Loc: \(xLoc + x) Y Loc: \(yLoc + y)") 
                
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
                
//                board[x + xLoc][y + yLoc].changed = true
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
    
    @objc func updateGame() {
        delegate?.gameDidUpdate(self)
        
//        NSLog("Game Update Calculation Begin")
        
//        Any live cell with fewer than two live neighbours dies, as if caused by under-population.
//        Any live cell with two or three live neighbours lives on to the next generation.
//        Any live cell with more than three live neighbours dies, as if by overcrowding.
//        Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard: [[Cell]] = board
        var allDead = true
        
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
                    }
                    else {
//                        NSLog("Wasted toggle (state bug = true)")
                    }
                }
                else {
                    if neighborCount == 3 {
                        toggleCell(x, yLoc: y, board: &newBoard)
                    }
                    else {
//                        NSLog("Wasted toggle (state bug = false)")
                    }
                }
            }
        }
        
        if allDead {
            updater.invalidate()
        }
        
        board = newBoard
        
//        NSLog("Game Update Calculation End")
    }
    
    func stopGame() {
        updater.invalidate()
        
        delegate?.gameDidEnd(self)
    }
}
