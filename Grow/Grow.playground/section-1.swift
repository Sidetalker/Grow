// Playground - noun: a place where people can play

import UIKit

let rows = 36
let cols = 25

let index = 21

let realX = index / rows
let realY = index % cols

var neighbors = []

for x in -1...1 {
    for y in -1...1 {
        var curNeighborX = realX + x
        var curNeighborY = realY + y
        
        if curNeighborX < 0 {
            curNeighborX = cols - 1
        }
        else if curNeighborX == cols {
            curNeighborX = e
        }
        
        if curNeighborY < 0 {
            curNeighborY = rows - 1
        }
        else if curNeighborY == rows {
            curNeighborY = 0
        }
    }
}

let newIndex = realX * cols + realY % rows

let testByte: Byte = 0x011011
testByte << 1

var newTest = [Byte]()
newTest.append(testByte)




