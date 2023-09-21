import SwiftUI

struct ContentView: View {
  let escape: Character = "\u{1B}"
  let tone = 10

  let melodyString: UInt8 = 3
  let myMidi = MyMidi()

  @State private var tempo: Int = 1
  @State private var strumsPerLoop: Int = 3
  @State private var input: String = ""

  @State private var lastNote: Character? = nil

  func soundOff(_ channel: UInt8, note: UInt8, _ tone: Int, _ volume: Int) {
    myMidi.noteOff(note: note)
  }

  func sound(_ channel: UInt8, _ note: UInt8, _ tone: Int, _ volume: Int) {
    print("sound \(channel): \(note) tone=\(tone) vol=\(volume)")
    myMidi.noteOn(note: note)
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
//              sound(melodyString, Notes.fretNumberToNote[key!]!, 10, strumVolume + 3)
//            }
//          }
        }

//        sound(0, 0, 0, 0)
//        sound(2, 0, 0, 0)
        soundOff(melodyString, note: 0, 0, 0)

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
          if lastNote != nil {
            let note = Notes.fretNumberToNote[lastNote!]!
            myMidi.noteOff(note: note)
          }
          lastNote = oneKey.characters.first!
          let note = Notes.fretNumberToNote[lastNote!]!
          myMidi.noteOn(note: note)

          return .handled
        }
        .onKeyPress(phases: .up) { press in
          if lastNote != nil {
            soundOff(melodyString, note: Notes.fretNumberToNote[lastNote!]!, 0, 0)
          }
          lastNote = nil
          return .handled
        }

      Button("Go") {
        play()
      }
    }
    .onAppear {
      myMidi.start()
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
