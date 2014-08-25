//
//  ConwayGame.swift
//  Grow
//
//  Created by Kevin Sullivan on 8/25/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation

protocol ConwayGameDelegate {
    func gameDidStart(game: ConwayGame)
    func gameDidUpdate(game: ConwayGame)
    func gameDidEnd(game: ConwayGame)
}

class ConwayGame {
    var board = [[Bool]]()
    var updater: NSTimer = NSTimer()
    var rows = 0
    var cols = 0
    var fps: Double = 1/30.0
    
    var delegate: ConwayGameDelegate?
    
    init (rows: Int, cols: Int) {
        self.board = [[Bool]](count: rows, repeatedValue: [Bool](count: cols, repeatedValue: Bool()))
        self.rows = rows
        self.cols = cols
    }
    
    func populateBoard (percent: Double) {
        for x in Range(start: 0, end: rows) {
            for y in Range(start: 0, end: cols) {
                var curRand = arc4random_uniform(100) + 1
                
                if Double(curRand) < percent {
                    board[x][y] = true
                }
            }
        }
    }
    
    func clearBoard() {
        self.board = [[Bool]](count: rows, repeatedValue: [Bool](count: cols, repeatedValue: Bool()))
    }
    
    func startGame() {
        delegate?.gameDidStart(self)
        
        updater = NSTimer.scheduledTimerWithTimeInterval(fps, target: self, selector: Selector("updateGame"), userInfo: nil, repeats: true)
    }
    
    @objc func updateGame() {
        delegate?.gameDidUpdate(self)
        
//        Any live cell with fewer than two live neighbours dies, as if caused by under-population.
//        Any live cell with two or three live neighbours lives on to the next generation.
//        Any live cell with more than three live neighbours dies, as if by overcrowding.
//        Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
        
        var newBoard = board
        var allDead = true
        
        for x in Range(start: 0, end: rows) {
            for y in Range(start: 0, end: cols) {
                var neighborCount = self.getNeighbors(x, col: y)
                
                if board[x][y] == true {
                    allDead = false
                    
                    if neighborCount < 2 || neighborCount > 3 {
                        newBoard[x][y] = false
                    }
                }
                else {
                    if neighborCount == 3 {
                        newBoard[x][y] = true
                    }
                }
            }
        }
        
        if allDead {
            updater.invalidate()
        }
        
        board = newBoard
    }
    
    func stopGame() {
        updater.invalidate()
        
        delegate?.gameDidEnd(self)
    }
    
    func getNeighbors (row: Int, col: Int) -> Int {
        var neighborCount = 0
        
        for x in -1...1 {
            for y in -1...1 {
                if (row + x) < 0 || (row + x) >= rows || (col + y) < 0 || (col + y) >= cols {
                    continue
                }
                
                if x == 0 && y == 0 {
                    continue
                }
                
                if board[x + row][y + col] {
                    neighborCount++
                }
            }
        }
        
        return neighborCount
    }
}
