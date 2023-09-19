import Foundation

public class Notes {
  static var keyboardToNote: [Character: Int] = [
    "q":173, "a":162, "w":153,
    "s":144, "e":136, "d":128,
    "f":121, "t":114, "g":108,
    "y":102, "h":96, "j":91,
    "i":85, "k":81, "o":76,
    "l":72, "p":68, ";":64,
    "+":60, "=":57, "*":53,
    "\n":50, "\'":47    // last 2 entries were return & caps
  ]

  static var fretNumberToNote: [Int: Int] = [
    0: 162,
    1: 144
  ]
}

