import SwiftUI

struct ContentView: View {
  let bassDrone = 0
  let middleDrone1 = 1
  let middleDrone2 = 2
  let melodyString = 3

  let myMidi = MyMidi()

  @State private var tempo: Int = 1
  @State private var strumsPerLoop: Int = 3
  @State private var input: String = ""

  @State private var lastNote: Character? = nil

  let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

  let strumPattern = [72, 64, 0, 0, 40, 0, 16, 0]
  @State var strumIndex = 0

  func soundOff(_ channel: Int, note: UInt8, _ tone: Int, _ volume: Int) {
    myMidi.noteOff(channel: channel, note: note)
  }

  fileprivate func playDrones(_ strumVolume: Int) {
    myMidi.noteOn(channel: bassDrone, note: 48, volume: strumVolume)
    myMidi.noteOn(channel: middleDrone1, note: 55, volume: strumVolume)
   // myMidi.noteOn(channel: middleDrone2, note: 55, volume: strumVolume)
  }
  
  var body: some View {
    Form {
      LabeledContent("Tempo") {
        TextField("Tempo", value: $tempo, format: .number)
      }
      LabeledContent("Strums/Loop") {
        TextField("Strums/Loop", value: $strumsPerLoop, format: .number)
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
        .onKeyPress(phases: .up) { press in
          if lastNote != nil {
            soundOff(melodyString, note: Notes.fretNumberToNote[lastNote!]!, 0, 0)
          }
          lastNote = nil
          return .handled
        }
    }
    .onReceive(timer) { _ in
      strumIndex = (strumIndex + 1) % strumPattern.count
      playDrones(strumPattern[strumIndex])
    }
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
