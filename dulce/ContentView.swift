import SwiftUI

struct ContentView: View {
  let escape = 27

  @State private var tempo: Int = 5
  @State private var strumsPerLoop: Int = 3
  @State private var input: String = ""

  @State private var lastNote: Int = 0

  func sound(_ channel: Int, _ note: Int, _ tone: Int, _ volume: Int) {
    print("sound \(channel): \(note) tone=\(tone) vol=\(volume)")
  }

  func LE(_ strum: Int) -> Int {
    3
  }

  func play() {
    while lastNote != escape {
      (1...strumsPerLoop).forEach { strum in

        for dur in stride(from: 6, to: 1, by: -LE(strum)) {
          sound(0, 163, 10, dur)
          sound(1, 243, 10, dur)
          sound(2, 161, 10, dur)

          (0...tempo).forEach { wait in
            let key = lastNote
            sound(3, Notes.fretNumberToNote[key]!, 10, dur + 3)
          }
        }

        sound(0, 0, 0, 0)
        sound(2, 0, 0, 0)
        sound(3, 0, 0, 0)
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
        .onKeyPress("0") {
          lastNote = 0
          return .handled
        }
        .onKeyPress("1") {
          lastNote = 1
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
