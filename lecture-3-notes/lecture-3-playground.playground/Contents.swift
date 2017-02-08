//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

1+1

// var can be changed
var x = 1+1
x = 2 + 1

// let cannot be changed
let y = 13

type(of: x)

y/2
y%2

(4+1)%5
5%5
6%5

// if we have 5 cells in game of life, use %5 to figure out wraparound rules
// | 0 | 1 | 2 | 3 | 4 |
// if you step right from 4, use (4+1)%5 = 0 to figure out where to land (0)
// if you step left from 0 to -1, use (-1 + 5)%5 = 4 to figure out where to land (4)

print(str)

var str2 = "\(y) blah"

let z = 3.14159
type(of: z)
// error below
//y + z
z + Double(y)

let a = ["a","b","c"]
type(of: a)
let b = [1,2,3]
type(of: b)
let c = ["d","e","f"]
type(of: c)
a+c
// error below
//a+b

// explicitly declaring types
var d: [Any] = ["a","b","c"]
type(of: d)
let e: [Any] = [1,2,3]
type(of: e)
d+e

// below will only work on vars not lets
d.append(47)

var dict = ["a": 1, "b": 2, "c": 3]
type(of: dict)
dict["d"] = 37

// dictionaries do not guarantee order
dict

dict.keys.sorted()
dict.values.sorted()

for (k,v) in dict {
    print ("\(k):\(v)")
}

//tuples
let t = (1,2)
let t2 = (row: 1, col: 2)
// above print the same
type(of: t)
type(of: t2)

let t3 = ("a",1)
type(of: t3)

t3.1
t.0
t2.0
t2.row

var t4 = (0, "a", [1,2,4,5], row: 2)
t4.2
t4.2[1]
t4.0 = 1

0 ..< 10
"a" ... "f"

for i in 0 ..< 10 {
    print("\(i)")
}

// countable range can be walked through
// closed range can only be used for contains test

// val is internal name
// -> Int indicates it's returning an int
func addOne(to val: Int) -> Int {
    return val + 1
}

// to is internal name
addOne(to: 13)

func addTwo(_ val: Int) -> Int {
    return val + 2
}
addTwo(5)

// functions are a type and can be passed as arguments to other functions
// passing functions and closures as arguments to each other

let s = [1,2,15,3,18,4].sorted {$0 < $1}
s
let s1 = [1,2,15,3,18,4]
    .sorted {$0 > $1}
    .map {$0 * 2}
s1

// 2d array, 3x3 of booleans (for game of life)
let aa:[[Bool]] = [[true, true, false], [false, true, false], [true, false, true]]
type(of: aa)

func compose(_ a: Int, _ b: (Int) -> Int) -> Int {
    return b(a)
}

func doubler(_ num: Int) -> Int {
    return num * 2
}

compose(8, doubler)

// trailing closure syntax to pass a function to another function
let val = compose(8) {$0 * $0}
val

