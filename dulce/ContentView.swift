import SwiftUI

enum FocusedField {
  case keyboard
}

struct ContentView: View {
  let escape: Character = "\u{1B}"
  let tone = 10

  let bassDrone = 0
  let middleDrone1 = 1
  let middleDrone2 = 2
  let melodyString = 3
  let myMidi = MyMidi()

  @State private var tempo: Int = 1
  @State private var strumsPerLoop: Int = 3
  @State private var input: String = ""

  @State private var lastNote: Character? = nil

  @FocusState private var focusedField: FocusedField?

  func soundOff(_ channel: Int, note: UInt8, _ tone: Int, _ volume: Int) {
    myMidi.noteOff(channel: channel, note: note)
  }

  func LE(_ strum: Int) -> Int {
    3
  }

  fileprivate func playDrones(_ strumVolume: Int) {
    myMidi.noteOn(channel: bassDrone, note: 48, volume: 64)
    myMidi.noteOn(channel: middleDrone1, note: 55, volume: 64)
    myMidi.noteOn(channel: middleDrone2, note: 55, volume: 64)
//    sound(0, 163, tone, strumVolume)
//    sound(1, 243, tone, strumVolume)
//    sound(2, 161, tone, strumVolume)
  }
  
  func play() {
    return
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
            myMidi.noteOff(channel: melodyString, note: note)
          }
          lastNote = oneKey.characters.first!
          let note = Notes.fretNumberToNote[lastNote!]!
          myMidi.noteOn(channel: melodyString, note: note, volume: 127)

          return .handled
        }
        .focused($focusedField, equals: FocusedField.keyboard)
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
    .defaultFocus($focusedField, .keyboard)
    .onAppear {
      myMidi.start()
      playDrones(64)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
