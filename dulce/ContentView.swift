import SwiftUI

struct ContentView: View {
  let escape: Character = "\u{1B}"
  let tone = 10
  let player = SoundPlayer()

  @State private var tempo: Int = 1
  @State private var strumsPerLoop: Int = 3
  @State private var input: String = ""

  @State private var lastNote: Character? = nil

  func sound(_ channel: Int, _ note: UInt8, _ tone: Int, _ volume: Int) {
    print("sound \(channel): \(note) tone=\(tone) vol=\(volume)")
    if channel == 3 {
      player.startPlayer()
      player.sound(note)
      _ = player.play(60)
    }
  }

  func LE(_ strum: Int) -> Int {
    3
  }

  fileprivate func playDrones(_ strumVolume: Int) {
    sound(0, 163, tone, strumVolume)
    sound(1, 243, tone, strumVolume)
    sound(2, 161, tone, strumVolume)
  }
  
  func play() {
    while lastNote != escape {
      (1...strumsPerLoop).forEach { strum in

        for strumVolume in stride(from: 6, to: 1, by: -LE(strum)) {
          playDrones(strumVolume)

//          (0...tempo).forEach { wait in
//            let key = lastNote
//            if key != nil && key != escape {
//              sound(3, Notes.fretNumberToNote[key!]!, 10, strumVolume + 3)
//            }
//          }
        }

        sound(0, 0, 0, 0)
        sound(2, 0, 0, 0)
        sound(3, 0, 0, 0)

        lastNote = escape
      }
    }

    print("reset")
  }

  var body: some View {
    Form {
      LabeledContent("Tempo") {
        TextField("Tempo", value: $tempo, format: .number)
      }
      LabeledContent("Strums/Loop") {
        TextField("Strums/Loop", value: $tempo, format: .number)
      }
      TextField("Play Here", text: $input)
        .onKeyPress(keys: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]) { oneKey in
          lastNote = oneKey.characters.first!
          sound(3, Notes.fretNumberToNote[lastNote!]!, 10, 6 + 3) // was dur

          return .handled
        }
        .onKeyPress(phases: .up) { press in
          lastNote = nil
          sound(3, 0, 0, 0)
          return .handled
        }

      Button("Go") {
        play()
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
