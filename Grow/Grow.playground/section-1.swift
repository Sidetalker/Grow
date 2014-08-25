// Playground - noun: a place where people can play

import UIKit

println("Hello World")

let constantDouble: Double = 4.0

let label = "The number is: "
let universe = 42
let universeLabel = label + String(universe)

let apples = 5
let oranges = 3
let appleString = "I have \(apples) apples"
let fruitString = "I have \(apples + oranges) fruits"

var shoppingList = ["catfish", "water", "tulips", "blue paint"]
shoppingList[1] = "bottle of water"

var occupations =
[
    "Malcolm": "Captain",
    "Kaylee": "Mechanic",
]
occupations["Jayne"] = "Public Relations"

occupations

let emptyArray = [String]()
let emptyDict = [String:Float]()
let emptyArrayInferred = []
let emptyDictInferred = [:]

let individualScores = [75, 43, 103, 87, 12]
var teamScore = 0
for score in individualScores {
    if score > 50 {
        teamScore += 3
    } else {
        teamScore += 1
    }
}

var optionalString: String? = "Hello"
optionalString == nil

var optionalName: String? = nil
optionalName = "Kevin"
var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
    println(greeting)
}
else {
    greeting = "This is sorta confusing to me... I think I got it"
    println(greeting)
}

let vegetable = "red"
var vegetableComment = "Nothing"

switch vegetable {
case "celery":
    vegetableComment = "Add some raisins and make ants on a log."
case "cucumber", "watercress":
    vegetableComment = "That would make a good tea sandwich."
case let x where x.hasSuffix("pepper"):
    vegetableComment = "Is it a spicy \(x)?"
default:
    vegetableComment = "Everything tastes good in soup."
}

println(vegetableComment)

var test = [[Bool]](count: 2, repeatedValue: [Bool](count: 4, repeatedValue: Bool()))
test[0][1] = true
test

